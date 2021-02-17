require "rails/engine"

module Sitepress
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      Sitepress.configure do |config|
        app.paths["app/helpers"].push config.site.helpers_path.expand_path
        app.paths["app/assets"].push config.site.assets_path.expand_path
        app.paths["app/views"].push config.site.root_path.expand_path
        app.paths["app/views"].push config.site.pages_path.expand_path
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
