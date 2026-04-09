require "forwardable"

module Sitepress
  # Configuration object for rails application.
  class RailsConfiguration
    # Store in ./app/content by default.
    DEFAULT_SITE_ROOT = "app/content".freeze

    attr_accessor :cache_resources
    attr_writer :site, :parent_engine

    def initialize
      # Caches sites between requests. Set to `false` for development environments.
      self.cache_resources = true
    end

    # Registry of additional `Sitepress::Site` instances for multi-site
    # apps. Lives on the configuration object so its lifecycle is tied
    # to the Rails app and tests can reset it via
    # `Sitepress.reset_configuration`.
    def sites
      @sites ||= Sites.new
    end

    def parent_engine
      @parent_engine ||= Rails.application
    end

    def site
      @site ||= pending_site || Site.new(root_path: default_root)
    end

    private

    def pending_site
      # Check for site set by standalone CLI before Rails was loaded
      Sitepress.respond_to?(:pending_site) && Sitepress.pending_site
    end

    def default_root
      Rails.root.join(DEFAULT_SITE_ROOT)
    end
  end
end
