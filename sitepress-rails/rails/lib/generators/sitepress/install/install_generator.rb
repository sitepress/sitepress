module Sitepress
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    class_option :skip_markdown, type: :boolean, default: false, desc: "Skip adding markdown-rails gem"

    def copy_files
      directory ".", "app/content"
    end

    def add_sitepress_routes
      route "sitepress_root"
      route "sitepress_pages"
    end

    def append_sitepress_path_to_tailwind_config
      # Tailwind v3
      if File.exist? 'config/tailwind.config.js'
        inject_into_file 'config/tailwind.config.js', ",\n    './app/content/**/*.*'",
          after: "    './app/views/**/*.{erb,haml,html,slim}'"
      # Tailwind v4
      elsif File.exist? 'app/assets/tailwind/application.css'
        inject_into_file 'app/assets/tailwind/application.css', "\n@source \"../../content/**/*.*\";",
          after: "@import \"tailwindcss\";"
      end
    end

    def add_markdown_rails_gem
      unless options[:skip_markdown]
        gem "markdown-rails"
        say "Added markdown-rails gem to Gemfile", :green
        say "Run 'bundle install' to install the gem", :yellow
      end
    end
  end
end
