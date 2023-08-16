require "forwardable"

module Sitepress
  # Configures Rails with the paths, etc. necessary to handle Sitepress sites in Rails.
  class Configuration
    # Store in ./app/content by default.
    DEFAULT_SITE_ROOT = "app/content".freeze

    attr_reader :root_path
    attr_accessor :cache_resources
    attr_writer :site, :parent_engine

    def initialize(root_path: self.class.default_root)
      @root_path = Pathname.new(root_path)
      # Caches sites between requests. Set to `false` for development environments.
      self.cache_resources = true
    end

    def parent_engine
      @parent_engine ||= Rails.application
    end

    def site
      @site ||= Site.new(pages_path: pages_path)
    end

    # Location of website pages.
    def pages_path
      @pages_path ||= root_path.join("pages")
    end

    # Location of helper files.
    def helpers_path
      @helpers_path ||= root_path.join("helpers")
    end

    # Location of rails assets
    def assets_path
      @assets_path ||= root_path.join("assets")
    end

    # Location of pages models
    def models_path
      @models_path ||= root_path.join("models")
    end

    def configure(app)
      # Set for view_components to load at ./components
      app.config.autoload_paths << File.expand_path("./components")

      app.paths["app/helpers"].push helpers_path.expand_path
      app.paths["app/assets"].push assets_path.expand_path
      app.paths["app/views"].push root_path.expand_path
      app.paths["app/views"].push pages_path.expand_path
      app.paths["app/models"].push models_path.expand_path
    end

    # Location of Sprockets manifest file
    def manifest_file_path
      assets_path.join("config/manifest.js")
    end

    def self.default_root
      Rails.root.join(DEFAULT_SITE_ROOT)
    end
  end
end
