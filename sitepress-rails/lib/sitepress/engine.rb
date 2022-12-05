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
    initializer :load_sitepress_file, before: :set_sitepress_paths do
      site_file = paths["config/site.rb"].existent.first
      load site_file if site_file
    end

    # Set the path for the site configuration file.
    paths.add "app/markdown", with: [
      File.expand_path("./markdown"),     # When Sitepress is launched via `sitepress server`.
      "app/markdown"                      # When Sitepress is launched embedded in Rails project.
    ], autoload: true

    # Load paths from `Sitepress#site` into rails so it can render views, helpers, etc. properly.
    initializer :set_sitepress_paths, before: :set_autoload_paths do |app|
      app.paths["app/helpers"].push site.helpers_path.expand_path
      app.paths["app/assets"].push site.assets_path.expand_path
      app.paths["app/views"].push site.root_path.expand_path
      app.paths["app/views"].push site.pages_path.expand_path
      app.paths["app/models"].push site.models_path.expand_path

      # Set for view_components to load at ./components
      app.config.autoload_paths << File.expand_path("./components")
    end

    # Configure sprockets paths for the site.
    initializer :set_manifest_file_path, before: :append_assets_path do |app|
      manifest_file = sitepress_configuration.manifest_file_path.expand_path
      app.config.assets.precompile << manifest_file.to_s if manifest_file.exist?
    end

    # Configure Sitepress with Rails settings.
    initializer :configure_sitepress do |app|
      sitepress_configuration.parent_engine = app
      # Reloads entire site between requests for development environments
      sitepress_configuration.cache_resources = app.config.cache_classes

      # If this isn't within the `ActiveSupport.on_load(:action_view)` block, it won't load templates
      # like haml that register the template handler in the same type of block.
      ActiveSupport.on_load(:action_view) do
        # Set the templates extensions (e.g. erb, haml) so that Sitepress can better parse paths.
        Sitepress::Path.handler_extensions = ActionView::Template::Handlers.extensions
      end
    end

    private

    def sitepress_configuration
      Sitepress.configuration
    end

    def site
      sitepress_configuration.site
    end
  end
end
