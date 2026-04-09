require "rails/generators/base"

module Sitepress
  # Scaffolds a new Sitepress site for multi-site Rails apps. Usage:
  #
  #   bin/rails generate sitepress:site app/sitepress/admin_docs
  #
  # See the USAGE file for the full description.
  class SiteGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    argument :root_path,
      type: :string,
      desc: "Path the site lives at on disk, relative to Rails root (e.g. app/sitepress/admin_docs)"

    class_option :mount_at,
      type: :string,
      desc: "URL prefix to mount the site at. When provided, injects a `scope` block into config/routes.rb instead of just printing the routes line."

    def create_content_directories
      empty_directory File.join(root_path, "pages")
      empty_directory File.join(root_path, "helpers")
      empty_directory File.join(root_path, "models")
      empty_directory File.join(root_path, "assets")

      create_file File.join(root_path, "helpers", ".keep"), ""
      create_file File.join(root_path, "models", ".keep"), ""
      create_file File.join(root_path, "assets", ".keep"), ""
    end

    def create_index_page
      template "index.html.erb", File.join(root_path, "pages", "index.html.erb")
    end

    def create_controller
      template "controller.rb.tt", File.join("app/controllers", "#{file_name}_controller.rb")
    end

    def register_site_in_initializer
      initializer_path = "config/initializers/sitepress.rb"
      registration_line = %(Sitepress.sites << Sitepress::Site.new(root_path: #{root_path.inspect})\n)
      absolute_initializer_path = File.join(destination_root, initializer_path)

      if File.exist?(absolute_initializer_path)
        append_to_file initializer_path, registration_line
      else
        create_file initializer_path, "# Multi-site Sitepress registry\n#{registration_line}"
      end
    end

    def mount_or_print_routes
      if options[:mount_at]
        inject_scope_into_routes(options[:mount_at])
      else
        print_routes_instructions
      end
    end

    private

    # When `--mount-at /admin/docs` is given, inject a `scope` block
    # into config/routes.rb right after `Rails.application.routes.draw do`.
    # Uses the standard Thor anchor that the Rails `route` action uses,
    # but writes a multi-line block instead of a single line.
    def inject_scope_into_routes(mount_path)
      # Strip leading slash so `scope "admin/docs" do` reads cleanly
      # (Rails treats the two as equivalent for path purposes).
      scope_path = mount_path.sub(%r{\A/}, "")

      block = <<~ROUTES
        scope #{scope_path.inspect} do
          sitepress_pages controller: #{file_name.inspect}, as: :#{file_name}
        end
      ROUTES

      indented = block.lines.map { |l| l.empty? ? l : "  #{l}" }.join

      inject_into_file "config/routes.rb",
        indented,
        after: /\.routes\.draw do(?:\s*\|.+?\|)?\s*\n/
    end

    def print_routes_instructions
      say ""
      say "Add this to config/routes.rb to mount the new site:", :green
      say ""
      say "  scope #{file_name.inspect} do"
      say "    sitepress_pages controller: #{file_name.inspect}, as: :#{file_name}"
      say "  end"
      say ""
      say "Or re-run with --mount-at=/path/to/mount to inject it automatically.", :yellow
      say ""
    end

    def file_name
      @file_name ||= File.basename(root_path)
    end

    def class_name
      @class_name ||= file_name.camelize
    end
  end
end
