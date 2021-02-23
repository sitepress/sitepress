require "thor"
require_relative "boot"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    SERVER_DEFAULT_PORT = 8080
    SERVER_DEFAULT_BIND_ADDRESS = "0.0.0.0".freeze
    COMPILE_DEFAULT_TARGET_PATH = "./build".freeze

    include Thor::Actions

    source_root File.expand_path("../../../templates/default", __FILE__)

    option :bind_address, default: SERVER_DEFAULT_BIND_ADDRESS, aliases: :a
    option :port, default: SERVER_DEFAULT_PORT, aliases: :p, type: :numeric
    desc "server", "Run preview server"
    def server
      Sitepress::Server.initialize!
      # This will use whatever server is found in the user's Gemfile.
      Rack::Server.start app: Sitepress::Server,
        Port: options.fetch("port"),
        Host: options.fetch("bind_address")
    end

    option :output_path, default: COMPILE_DEFAULT_TARGET_PATH, type: :string
    desc "compile", "Compile project into static pages"
    def compile
      Sitepress::Server.initialize!
      # Sprockets compilation
      logger.info "Sitepress compiling assets"
      sprockets_manifest(target_path: options.fetch("output_path")).compile precompile_assets
      # Page compilation
      logger.info "Sitepress compiling pages"
      compiler.compile target_path: options.fetch("output_path")
    end

    desc "console", "Interactive project shell"
    def console
      Sitepress::Server.initialize!
      # Start's an interactive console.
      REPL.new(context: configuration).start
    end

    desc "new PATH", "Create new project at PATH"
    def new(target)
      inside target do
        directory self.class.source_root, "."
        run "bundle install"
      end
    end

    desc "version", "Show version"
    def version
      say "Sitepress #{Sitepress::VERSION}"
    end

    private
    def configuration
      Sitepress.configuration
    end

    def compiler
      Compiler.new(site: configuration.site)
    end

    def sprockets_manifest(target_path: )
      target_path = Pathname.new(target_path)
      Sprockets::Manifest.new(rails.assets, target_path.join("assets/manifest.json")).tap do |manifest|
        manifest.environment.logger = logger
      end
    end

    def rails
      configuration.parent_engine
    end

    def logger
      rails.config.logger
    end

    def precompile_assets
      rails.config.assets.precompile
    end
  end
end
