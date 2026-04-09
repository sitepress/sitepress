module Sitepress
  # Registry of `Sitepress::Site` instances for multi-site Rails apps.
  #
  # The whole multi-site API lives on this collection — `<<` to register,
  # `fetch` to look up by `root_path`, `each` (and the rest of `Enumerable`)
  # to iterate. There's intentionally no `[]`, no `add`, no `find`-by-block,
  # and no `delete` — three methods plus Enumerable is the entire surface,
  # so callers don't have to choose between soft-miss and hard-miss lookup
  # forms or between `<<` and a non-chaining `add`.
  #
  #   # config/initializers/sitepress.rb
  #   Sitepress.sites << Sitepress::Site.new(root_path: "app/content/admin_docs")
  #
  #   # somewhere later
  #   Sitepress.sites.fetch("app/content/admin_docs")    # => Sitepress::Site
  #   Sitepress.sites.fetch("nope")                        # => raises NotFoundError
  #   Sitepress.sites.each { |site| ... }
  #
  # The collection holds Sites directly — there's no derived key stored
  # alongside, so the "key drift" failure mode (registry key disagreeing
  # with the value's actual root_path) is impossible by construction.
  # Lookup is a linear scan over `Site#root_path`, which is fine because
  # registration is rare (boot time) and lookups happen at controller class
  # load (also boot, in production).
  class Sites
    include Enumerable

    def initialize
      @sites = []
    end

    # Register a Site. Returns self per Ruby's `<<` convention so
    # `Sitepress.sites << a << b` chains correctly.
    #
    # Two safety checks:
    #
    # - Type-checks `site` so the common mistake of pushing a path
    #   string instead of a constructed Site fails loudly at the
    #   call site rather than later when the engine tries to read
    #   `.helpers_path` on a String.
    #
    # - If the engine's path-setup pass has already finished (i.e.
    #   `<<` is being called from `config.after_initialize`, a
    #   request, or anywhere else that runs after initializers), the
    #   site is registered but its helpers/models/assets won't be on
    #   Zeitwerk's autoload paths. We log a warning so the user can
    #   diagnose the silent half-broken state instead of debugging
    #   "why isn't my AdminDocsHelper resolving" three days later.
    def <<(site)
      unless site.is_a?(Sitepress::Site)
        raise ArgumentError,
          "Sitepress.sites << expects a Sitepress::Site, got #{site.class}: #{site.inspect}. " \
          "Wrap it: Sitepress.sites << Sitepress::Site.new(root_path: #{site.inspect})"
      end

      if Sitepress.respond_to?(:configuration) &&
         Sitepress.configuration.instance_variable_get(:@boot_paths_registered) &&
         defined?(Rails) && Rails.logger
        Rails.logger.warn(
          "Sitepress.sites << #{site.root_path.inspect} called after the engine's " \
          "path-setup pass. The site is registered, but its helpers, models, and " \
          "assets won't be on Zeitwerk's autoload paths. Move this call into " \
          "config/initializers/ if you want Rails to discover them."
        )
      end

      @sites << site
      self
    end

    # Find a registered Site by its `root_path`. Raises `NotFoundError`
    # listing the registered paths if nothing matches — there's no nil
    # return form, so a typo in the path string fails loud at the call
    # site instead of propagating into a `NoMethodError on nil` later.
    def fetch(root_path)
      key = root_path.to_s
      @sites.find { |site| site.root_path.to_s == key } || raise(
        NotFoundError,
        "No Sitepress site registered at #{root_path.inspect}. " \
          "Registered: #{@sites.map { |s| s.root_path.to_s }.inspect}"
      )
    end

    def each(&block)
      @sites.each(&block)
    end
  end
end
