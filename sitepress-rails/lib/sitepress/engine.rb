require "rails/engine"
require "sitepress/routing_mapper"

module Sitepress
  class Engine < ::Rails::Engine
    # Set the root of the engine to the gems rails directory.
    config.root = File.expand_path("../../rails", __dir__)

    # Set the path for the site configuration file.
    paths.add "config/site.rb", with: [
      File.expand_path("./config/site.rb"), # When Sitepress is launched via `sitepress server`.
      "config/site.rb"                      # When Sitepress is launched embedded in Rails project.
    ]

    # Load the `config/site.rb` file so users can configure Sitepress.
    initializer "sitepress.load_site_file", before: "sitepress.set_paths" do
      site_file = paths["config/site.rb"].existent.first
      load site_file if site_file
    end

    # Set the path for the site configuration file.
    paths.add "app/markdown", with: [
      File.expand_path("./markdown"),     # When Sitepress is launched via `sitepress server`.
      "app/markdown"                      # When Sitepress is launched embedded in Rails project.
    ], autoload: true

    # Load paths from `Sitepress#site` into Rails.
    #
    # We configure two separate systems:
    #
    # 1. app.paths["app/*"] - Rails component path registry
    #    Tells ActionView where to find templates, ActionController where to find helpers, etc.
    #
    # 2. config.autoload_paths - Zeitwerk autoloader configuration
    #    Tells Zeitwerk what to autoload. Rails automatically includes these in
    #    config.eager_load_paths for production environments.
    #
    initializer "sitepress.set_paths", before: :set_autoload_paths do |app|
      site = Sitepress.configuration.site

      # Helpers: autoloadable and available to controllers
      # Collapsed so app/content/helpers/sample_helper.rb defines SampleHelper (not Helpers::SampleHelper)
      site.helpers_path.expand_path.tap do |path|
        if path.exist?
          app.paths["app/helpers"].push path
          app.config.autoload_paths << path
          app.config.eager_load_paths << path
          Rails.autoloaders.main.push_dir(path)
          Rails.autoloaders.main.collapse(path)
        end
      end

      # Models: autoloadable
      # Collapsed so models don't require namespace prefixes
      site.models_path.expand_path.tap do |path|
        if path.exist?
          app.paths["app/models"].push path
          app.config.autoload_paths << path
          app.config.eager_load_paths << path
          Rails.autoloaders.main.push_dir(path)
          Rails.autoloaders.main.collapse(path)
        end
      end

      # Assets: available to Propshaft (no autoloading needed)
      app.paths["app/assets"].push site.assets_path.expand_path

      # Views: available to ActionView (no autoloading needed - these are templates)
      app.paths["app/views"].push site.root_path.expand_path
      app.paths["app/views"].push site.pages_path.expand_path

      # Components: autoloadable for view_components
      app.config.autoload_paths << File.expand_path("./components")
    end

    # Configure asset paths for the site.
    initializer "sitepress.set_manifest_file_path", before: :append_assets_path do |app|
      manifest_file = Sitepress.configuration.manifest_file_path.expand_path
      app.config.assets.precompile << manifest_file.to_s if manifest_file.exist?
    end

    # Configure Sitepress with Rails settings.
    initializer "sitepress.configure" do |app|
      Sitepress.configuration.parent_engine = app
      # Reloads entire site between requests for development environments.
      Sitepress.configuration.cache_resources = if app.config.respond_to? :enable_reloading?
        # Rails 7.1 changed the name of this setting to enable_reloading, so check if that exist and use it.
        app.config.enable_reloading?
      else
        # Rails 7.0.x and lower all use this method to check if reloading is enabled.
        app.config.cache_classes
      end
    end
  end
end
