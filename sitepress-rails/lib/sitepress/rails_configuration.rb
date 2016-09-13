require "forwardable"

module Sitepress
  # Configuration object for rails application.
  class RailsConfiguration
    # Store in ./app/content by default.
    DEFAULT_SITE_ROOT = "app/content".freeze

    attr_accessor :site, :parent_engine, :routes, :cache_resources

    # Delegates configuration points into the Sitepress site.
    extend Forwardable
    def_delegators :site, :cache_resources, :cache_resources=, :cache_resources?

    # Set defaults.
    def initialize
      self.routes = true
      self.parent_engine = Rails.application
      self.cache_resources = parent_engine.config.cache_classes
    end

    def site
      @site ||= Site.new(root_path: default_root, cache_resources: @cache_resources).tap do |site|
        site.resources_pipeline << Extensions::PartialsRemover.new
        site.resources_pipeline << Extensions::RailsRequestPaths.new
      end
    end

    private
    def default_root
      Rails.root.join(DEFAULT_SITE_ROOT)
    end
  end
end
