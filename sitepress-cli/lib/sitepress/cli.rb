require "thor"
require "rack"
require "sitepress-server"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    DEFAULT_SERVER_PORT = 8080
    DEFAULT_SERVER_BIND_ADDRESS = "0.0.0.0".freeze

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :bind_address, default: DEFAULT_SERVER_BIND_ADDRESS, aliases: :a
    option :port, default: DEFAULT_SERVER_PORT, aliases: :p, type: :numeric
    desc "server", "Run preview server"
    def server
      Rack::Handler::WEBrick.run project.preview_server,
        BindAddress: options.fetch("bind_address"),
        Port: options.fetch("port")
    end

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :output_path, default: "./build"
    desc "compile", "Compile project into static pages"
    def compile
      project.compiler.compile target_path: options.fetch("output_path")
    end

    # desc "new", "Create a Sitepress project"
    # def new
    #   puts "Creating new Sitepress project..."
    # end

    private
    def project
      @_project ||= Sitepress::Project.new config_file: options.fetch("config_file")
    end
  end
end
