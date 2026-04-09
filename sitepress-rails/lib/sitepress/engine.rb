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

    # Load paths from Sitepress sites into Rails.
    #
    # The work is split across two initializers because of Rails' boot
    # ordering: the *default* site is set up before `:set_autoload_paths`
    # (so its paths land in `config.autoload_paths` the normal way),
    # but *registered* sites have to wait until after
    # `:load_config_initializers` runs — that's where the user's
    # `config/initializers/sitepress.rb` (with `Sitepress.sites << ...`)
    # populates the registry. By the time we iterate the registry,
    # `:set_autoload_paths` has already frozen `config.autoload_paths`,
    # so we push paths directly to `Rails.autoloaders.main` (which
    # accepts additions any time before eager loading).
    #
    # The default site gets views added to `app/views` globally; the
    # default `Sitepress::SiteController` reads from there. Registered
    # sites' views live on the controller via `prepend_view_path` so
    # multi-site view lookups stay local to the controller.

    initializer "sitepress.set_default_site_paths", before: :set_autoload_paths do |app|
      site = Sitepress.configuration.site

      site.helpers_path.expand_path.tap do |path|
        if path.exist?
          app.paths["app/helpers"].push path
          app.config.autoload_paths << path
          app.config.eager_load_paths << path
          Rails.autoloaders.main.push_dir(path)
          Rails.autoloaders.main.collapse(path)
        end
      end

      site.models_path.expand_path.tap do |path|
        if path.exist?
          app.paths["app/models"].push path
          app.config.autoload_paths << path
          app.config.eager_load_paths << path
          Rails.autoloaders.main.push_dir(path)
          Rails.autoloaders.main.collapse(path)
        end
      end

      app.paths["app/assets"].push site.assets_path.expand_path
      app.paths["app/views"].push  site.root_path.expand_path
      app.paths["app/views"].push  site.pages_path.expand_path
    end

    initializer "sitepress.set_registered_site_paths", after: :load_config_initializers do |app|
      # `config.autoload_paths` and `config.eager_load_paths` are frozen
      # by the time `:load_config_initializers` finishes, but
      # `Rails.autoloaders.main.push_dir` accepts new directories any
      # time before eager loading. Registered sites' helpers/models
      # become lazy-autoloadable through that path. They're not added
      # to `eager_load_paths`, so in production they're loaded on first
      # access rather than at boot — fine for the multi-site case
      # where the secondary site's helpers are scoped to one controller.
      register_helpers_late = ->(path) {
        if path.exist?
          Rails.autoloaders.main.push_dir(path)
          Rails.autoloaders.main.collapse(path)
        end
      }

      register_assets_late = ->(path) {
        # Propshaft reads config.assets.paths lazily, so adding here
        # works for both dev and production precompile.
        app.config.assets.paths << path.to_s if app.config.respond_to?(:assets)
      }

      Sitepress.configuration.sites.each do |site|
        register_helpers_late.call site.helpers_path.expand_path
        register_helpers_late.call site.models_path.expand_path
        register_assets_late.call  site.assets_path.expand_path
      end

      # Mark that boot-time path registration has finished. Sites#<<
      # checks this and warns if a site is registered after this point,
      # since its helpers/models/assets won't be picked up by Zeitwerk.
      Sitepress.configuration.instance_variable_set(:@boot_paths_registered, true)
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
