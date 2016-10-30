require "thor"
require "sitepress-server"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :bind_address, default: PreviewServer::DEFAULT_BIND_ADDRESS, aliases: :a
    option :port, default: PreviewServer::DEFAULT_PORT, aliases: :p, type: :numeric
    desc "server", "Run preview server"
    def server
      PreviewServer.new(project: project).run port: options.fetch("port"),
        bind_address: options.fetch("bind_address")
    end

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :output_path, default: "./build"
    desc "compile", "Compile project into static pages"
    def compile
      project.compiler.compile target_path: options.fetch("output_path")
    end

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    desc "console", "REPL for site"
    def console
      REPL.new(context: project).start
    end

    desc "new", "Create a Sitepress project"
    def new
      puts "Creating new Sitepress project..."
    end

    private
    def project
      @_project ||= Sitepress::Project.new config_file: options.fetch("config_file")
    end
  end
end
