module Mascot
  # Configuration object for rails application.
  class RailsConfiguration
    # Store in ./app/pages by default.
    DEFAULT_SITEMAP_ROOT = "app/pages".freeze

    attr_accessor :sitemap, :resources, :parent_engine, :routes, :cache_resources

    # Set defaults.
    def initialize
      @routes = true
      @parent_engine = Rails.application
      @cache_resources = @parent_engine.config.cache_classes
    end

    def sitemap
      @sitemap ||= Sitemap.new(root: default_root)
    end

    def resources
      # Production will cache resources globally. This drastically speeds up
      # the speed at which resources are served, but if they change it won't be updated.
      @resources = nil unless cache_resources?
      @resources ||= sitemap.resources
    end

    def cache_resources?
      !!@cache_resources
    end

    private
    def default_root
      Rails.root.join(DEFAULT_SITEMAP_ROOT)
    end
  end
end
