require "rails/engine"

module Sitepress
  class Engine < ::Rails::Engine
    # Set the path for the site configuration file.
    paths.add "config/site.rb", with: [
      File.expand_path("./config/site.rb"), # When Sitepress is launched via `sitepress server`.
      "config/site.rb"                      # When Sitepress is launched embedded in Rails project.
    ]

    # Load the `config/site.rb` file so users can configure Sitepress.
    initializer :load_site_file, before: :set_site_paths do
      site_file = paths["config/site.rb"].existent.first
      load site_file if site_file
    end

    # Load paths from `Sitepress#site` into rails so it can render views, helpers, etc. properly.
    initializer :set_site_paths, before: :set_autoload_paths do |app|
      app.paths["app/helpers"].push site.helpers_path.expand_path
      app.paths["app/assets"].push site.assets_path.expand_path
      app.paths["app/views"].push site.root_path.expand_path
      app.paths["app/views"].push site.pages_path.expand_path
    end

    # Configure Sitepress with Rails settings.
    initializer :configure_sitepress do |app|
      sitepress_configuration.parent_engine = app
      sitepress_configuration.cache_resources = app.config.cache_classes
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
