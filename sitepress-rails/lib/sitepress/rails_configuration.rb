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

    def parent_engine
      @parent_engine ||= Rails.application
    end

    def site
      @site ||= Site.from_path(default_root)
    end

    def paths
      Sitepress::Configuration::RailsPaths.new(root_path: default_root)
    end

    # Location of Sprockets manifest file
    def manifest_file_path
      paths.assets_path.join("config/manifest.js")
    end

    private
    def default_root
      Rails.root.join(DEFAULT_SITE_ROOT)
    end
  end
end
