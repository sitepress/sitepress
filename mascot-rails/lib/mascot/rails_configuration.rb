module Mascot
  # Configuration object for rails application.
  class RailsConfiguration
    # Store in ./app/pages by default.
    DEFAULT_SITEMAP_ROOT = "app/pages".freeze

    # Partial rails prefix.
    PARTIAL_PREFIX = "_".freeze

    attr_accessor :sitemap, :resources, :parent_engine, :routes, :cache_resources, :partials

    # Set defaults.
    def initialize
      @routes = true
      @parent_engine = Rails.application
      @cache_resources = @parent_engine.config.cache_classes
      @partials = false
    end

    def sitemap
      @sitemap ||= Sitemap.new(root: default_root)
    end

    def resources
      # Production will cache resources globally. This drastically speeds up
      # the speed at which resources are served, but if they change it won't be updated.
      @resources = nil unless cache_resources?
      @resources ||= remove_partials sitemap.resources
    end

    def cache_resources?
      !!@cache_resources
    end

    private
    def default_root
      Rails.root.join(DEFAULT_SITEMAP_ROOT)
    end

    def remove_partials(resources)
      resources.each do |r|
        if not partials
          resources.remove r if r.asset.path.basename.to_s.starts_with? PARTIAL_PREFIX # Looks like a smiley face, doesn't it?
        end
      end
      resources
    end
  end
end
