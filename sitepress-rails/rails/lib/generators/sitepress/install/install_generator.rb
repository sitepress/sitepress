module Sitepress
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_files
      directory ".", "app/content"
    end

    def add_sitepress_routes
      route "sitepress_root"
      route "sitepress_pages site: Sitepress::SiteController.site"
    end

    def append_sitepress_path_to_tailwind_config
      inject_into_file 'config/tailwind.config.js', ",\n    './app/content/**/*.{erb,haml,html,slim,rb}'",
        after: "    './app/views/**/*.{erb,haml,html,slim}'"
    end
  end
end
