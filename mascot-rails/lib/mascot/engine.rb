module Mascot
  class Engine < ::Rails::Engine
    initializer "Add site root to view paths" do |app|
      ActionController::Base.prepend_view_path Mascot.configuration.site.root_path
    end
  end
end
