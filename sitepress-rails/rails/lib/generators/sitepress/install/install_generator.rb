module Sitepress
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_files
      directory ".", "app/content"
    end

    def add_nopassword_routes
      route "sitepress_pages"
    end
  end
end
