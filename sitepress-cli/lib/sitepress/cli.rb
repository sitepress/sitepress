require "thor"

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
      initialize!
      # Enable Sitepress web error reporting so users have more friendly
      # error messages instead of seeing a Rails exception.
      controller.enable_sitepress_error_reporting = true
      # Enable reloading the site between requests so we can see changes.
      controller.enable_site_reloading = true
      # This will use whatever server is found in the user's Gemfile.
      Rack::Server.start app: app,
        Port: options.fetch("port"),
        Host: options.fetch("bind_address")
    end

    option :output_path, default: COMPILE_DEFAULT_TARGET_PATH, type: :string
    desc "compile", "Compile project into static pages"
    def compile
      initialize!
      # Page compilation
      logger.info "Sitepress compiling pages"
      Compiler.new(site: configuration.site, root_path: options.fetch("output_path")).compile
      # Sprockets compilation
      logger.info "Sitepress compiling assets"
      sprockets_manifest(target_path: options.fetch("output_path")).compile precompile_assets
    end

    desc "console", "Interactive project shell"
    def console
      initialize!
      # Start's an interactive console.
      REPL.new(context: configuration).start
    end

    desc "new PATH", "Create new project at PATH"
    def new(target)
      # Peg the generated site to roughly the released version.
      *segments, _ = Gem::Version.new(Sitepress::VERSION).segments
      @target_sitepress_version = segments.join(".")

      inside target do
        directory self.class.source_root, "."
        run "bundle install"
      end
    end

    desc "version", "Show version"
    def version
      say Sitepress::VERSION
    end

    private
    def configuration
      Sitepress.configuration
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

    def initialize!
      require_relative "boot"
      app.initialize!
    end

    def controller
      ::SiteController
    end

    def app
      Sitepress::Server
    end
  end
end
