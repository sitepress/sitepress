module Sitepress
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      Sitepress.configure do |config|
        app.paths["app/helpers"].push config.site.root_path.join("helpers")
        app.paths["app/assets"].push config.site.root_path.join("assets")
        app.paths["app/views"].push config.site.root_path
      end
    end

    initializer "sitepress.configure" do |app|
      Sitepress.configure do |config|
        config.parent_engine = app
        config.cache_resources = app.config.cache_classes
      end
    end
  end
end
