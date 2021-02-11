require "rails/engine"

module Sitepress
  class Engine < ::Rails::Engine
    initializer "sitepress.configure" do |app|
      Sitepress.configure do |config|
        config.parent_engine = app
        config.cache_resources = app.config.cache_classes
      end
    end
  end
end
