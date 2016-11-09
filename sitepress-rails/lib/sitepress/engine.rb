module Sitepress
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      Sitepress.configure do |config|
        app.paths["app/helpers"].push config.site.root_path.join("helpers")
        app.paths["app/assets"].push config.site.root_path.join("assets")
        app.paths["app/views"].push config.site.root_path
      end

      # Setup concerns paths for Rails 4 (doesn't automatically populate)
      concerns_path = "app/controllers/concerns"
      unless app.paths.keys.include?(concerns_path)
        app.paths.add(concerns_path)
      end
    end

    initializer "sitepress.configure" do |app|
      Sitepress.configure do |config|
        config.parent_engine = app
        config.cache_resources = app.config.cache_classes
      end
    end

    initializer "sitepress.middleware" do |app|
      app.middleware.use Sitepress::Middleware::RequestCache, site: Sitepress.site
    end
  end
end
