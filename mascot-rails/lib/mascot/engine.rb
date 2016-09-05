module Mascot
  class Engine < ::Rails::Engine
    initializer "Add site root to view paths" do |app|
      ActionController::Base.prepend_view_path Mascot.configuration.site.root_path
    end

    initializer "Require concerns path" do |app|
      concerns_path = "app/controllers/concerns"

      unless app.paths.keys.include?(concerns_path)
        app.paths.add(concerns_path)
      end
    end
  end
end
