class Sitepress::ControllerGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    directory ".", "app"
  end

  def append_controller_to_sitepress_root_route
    inject_into_file "config/routes.rb", after: "sitepress_root" do
      " controller: :site"
    end
  end

  def append_controller_to_sitepress_pages_route
    inject_into_file "config/routes.rb", after: "sitepress_pages" do
      " controller: :site"
    end
  end
end
