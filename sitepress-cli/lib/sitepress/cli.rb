require "thor"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    # Default port address for server port.
    SERVER_PORT = 8080

    # Default address is public to all IPs.
    SERVER_BIND_ADDRESS = "0.0.0.0".freeze

    # Default build path for compiler.
    COMPILE_TARGET_PATH = "./build".freeze

    # Display detailed error messages to the developer. Useful for development environments
    # where the error should be displayed to the developer so they can debug errors.
    SERVER_SITE_ERROR_REPORTING = true

    # Reload the site between requests, useful for development environments when
    # the site has to be rebuilt between requests. Disable in production environments
    # to run the site faster.
    SERVER_SITE_RELOADING = true

    include Thor::Actions

    source_root File.expand_path("../../../templates/default", __FILE__)

    option :bind_address, default: SERVER_BIND_ADDRESS, aliases: :a
    option :port, default: SERVER_PORT, aliases: :p, type: :numeric
    option :site_reloading, default: SERVER_SITE_RELOADING, aliases: :r, type: :boolean
    option :site_error_reporting, default: SERVER_SITE_ERROR_REPORTING, aliases: :e, type: :boolean
    desc "server", "Run preview server"
    def server
      # Now boot everything for the Rack server to pickup.
      initialize! do |app|
        # Enable Sitepress web error reporting so users have more friendly
        # error messages instead of seeing a Rails exception.
        app.config.enable_site_error_reporting = options.fetch("site_error_reporting")

        # Enable reloading the site between requests so we can see changes.
        app.config.enable_site_reloading = options.fetch("site_reloading")
      end

      # This will use whatever server is found in the user's Gemfile.
      Rack::Server.start app: app,
        Port: options.fetch("port"),
        Host: options.fetch("bind_address")
    end

    option :output_path, default: COMPILE_TARGET_PATH, type: :string
    option :fail_on_error, default: false, type: :boolean
    desc "compile", "Compile project into static pages"
    def compile
      initialize!

      logger.info "Sitepress compiling assets"
      sprockets_manifest(target_path: options.fetch("output_path")).compile precompile_assets

      logger.info "Sitepress compiling pages"
      compiler = Compiler.new(
        site: configuration.site,
        root_path: options.fetch("output_path"),
        fail_on_error: options.fetch("fail_on_error")
      )

      begin
        compiler.compile
      ensure
        logger.info ""
        logger.info "Compilation Summary"
        logger.info "  Build path: #{compiler.root_path.expand_path}"
        logger.info "  Succeeded:  #{compiler.succeeded.count}"
        logger.info "  Failed:     #{compiler.failed.count}"
        logger.info ""
        logger.info "Failed Resources"
        compiler.failed.each do |resource|
          logger.info "  #{resource.request_path}  #{resource.asset.path}"
        end
      end
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

    def initialize!(&block)
      require_relative "boot"
      app.tap(&block) if block_given?
      app.initialize!
    end

    def app
      Sitepress::Server
    end
  end
end
