require "forwardable"

module Sitepress
  # Configuration object for rails application.
  class RailsConfiguration
    # Store in ./app/content by default.
    DEFAULT_SITE_ROOT = "app/content".freeze

    attr_accessor :routes
    attr_writer :site, :parent_engine

    # Delegates configuration points into the Sitepress site.
    extend Forwardable
    def_delegators :site, :cache_resources, :cache_resources=, :cache_resources?

    # Set defaults.
    def initialize
      self.routes = true
    end

    def parent_engine
      @parent_engine ||= Rails.application
    end

    def site
      @site ||= begin
        Site.new(root_path: default_root)
      end
    end

    private
    def default_root
      Rails.root.join(DEFAULT_SITE_ROOT)
    end
  end
end
