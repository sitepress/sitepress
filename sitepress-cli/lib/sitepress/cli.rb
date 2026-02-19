require "thor"
require "rackup/server"
require_relative "commands"
require_relative "cli/command_helpers"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    # Boot Sitepress and load commands before processing.
    def self.start(given_args = ARGV, config = {})
      load_commands!
      boot!
      super
    end

    class << self
      private

      def load_commands!
        return if @commands_loaded

        Commands.discover!
        Commands.each do |name, command|
          register(command[:cli], name, "#{name} SUBCOMMAND", command[:description])
        end

        @commands_loaded = true
      end

      def boot!
        return if @booted
        require File.expand_path("../boot", __FILE__)
        Sitepress::Server.initialize!
        @booted = true
      end
    end
    # Default port address for server port.
    SERVER_PORT = 8080

    # Default address is public to all IPs.
    SERVER_BIND_ADDRESS = "127.0.0.1".freeze

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
    desc "server", "Run preview server"
    def server
      Rackup::Server.start app: app,
        Port: options.fetch("port"),
        Host: options.fetch("bind_address")
    end

    option :output_path, default: COMPILE_TARGET_PATH, type: :string
    option :fail_on_error, default: false, type: :boolean
    desc "compile", "Compile project into static pages"
    def compile
      logger.info "Sitepress compiling assets"
      rails.assets.reveal(full_path: Pathname.new(options.fetch("output_path")).join("assets"))

      logger.info "Sitepress compiling pages"
      compiler = Compiler::Files.new \
        site: configuration.site,
        root_path: options.fetch("output_path"),
        fail_on_error: options.fetch("fail_on_error")

      begin
        compiler.compile
      ensure
        logger.info ""
        logger.info "Compilation Summary"
        logger.info "  Build path: #{compiler.root_path.expand_path}"
        logger.info "  Succeeded:  #{compiler.succeeded.count}"
        logger.info "  Failed:     #{compiler.failed.count}"
        if compiler.failed.any?
          logger.info ""
          logger.info "Failed Resources"
          compiler.failed.each do |resource|
            logger.info "  #{resource.request_path}  #{resource.asset.path}"
          end
          abort # We want a non-zero exit code so we can fail CI pipelines, etc.
        end
      end
    end

    desc "console", "Interactive project shell"
    def console
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

    # Include shared helpers (available to command extensions too)
    include CommandHelpers
    private :initialize!, :app, :configuration, :site, :rails, :logger
  end
end
