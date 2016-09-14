module Sitepress
  class Engine < ::Rails::Engine
    config.before_configuration do |app|
      app.paths["app/helpers"].push Sitepress.site.root_path.join("helpers")
      app.paths["app/views"].push Sitepress.site.root_path

      # Setup concerns paths for Rails 4 (doesn't automatically populate)
      concerns_path = "app/controllers/concerns"
      unless app.paths.keys.include?(concerns_path)
        app.paths.add(concerns_path)
      end
    end
  end
end
