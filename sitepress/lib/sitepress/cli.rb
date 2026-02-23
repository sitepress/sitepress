require "thor"
require "fileutils"

module Sitepress
  # Command line interface for Sitepress sites.
  class CLI < Thor
    # Default build path for compiler.
    COMPILE_TARGET_PATH = "./build".freeze

    # Site configuration file
    SITE_CONFIG_PATH = "config/site.rb".freeze

    include Thor::Actions

    source_root File.expand_path("../../../templates/default", __FILE__)

    option :port, aliases: "-p", type: :numeric, desc: "Port to run server on"
    option :host, aliases: "-h", type: :string, desc: "Host to bind server to"
    desc "server", "Run development server"
    def server
      setup_environment!
      load_site_config!(validate: false)

      unless Sitepress.server
        say "Error: Server not configured in #{SITE_CONFIG_PATH}", :red
        say "Add: Sitepress.server = Sitepress::ApplicationServer.new(site)"
        exit 1
      end

      # Override port/host if specified on command line
      Sitepress.server.port = options[:port] if options[:port]
      Sitepress.server.host = options[:host] if options[:host]

      Sitepress.server.run
    end

    option :output_path, default: COMPILE_TARGET_PATH, type: :string
    option :fail_on_error, default: false, type: :boolean
    desc "compile", "Compile project into static pages"
    def compile
      setup_environment!
      load_site_config!(validate: false)
      setup_site_from_server!
      initialize_rails_app!

      logger.info "Sitepress compiling assets"
      compile_assets(Pathname.new(options.fetch("output_path")).join("assets"))

      logger.info "Sitepress compiling pages"
      compiler = Compiler::Files.new \
        site: Sitepress.site,
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
          abort
        end
      end
    end

    desc "console", "Interactive project shell"
    def console
      setup_environment!
      load_site_config!(validate: false)
      setup_site_from_server!
      initialize_rails_app!
      REPL.new(site: Sitepress.site).start
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

    def setup_environment!
      unless File.exist?(SITE_CONFIG_PATH)
        say "Error: #{SITE_CONFIG_PATH} not found.", :red
        say "Run 'sitepress new .' to create a new project in the current directory."
        exit 1
      end

      # Set up Bundler if Gemfile exists
      if File.exist?("Gemfile")
        ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")
        require "bundler/setup"
      end
    end

    def load_site_config!(validate: true)
      config_path = File.expand_path(SITE_CONFIG_PATH)
      load config_path

      # Ensure site is configured (check the raw instance variable to avoid auto-creating default)
      if validate && !Sitepress.configuration.instance_variable_get(:@site)
        say "Error: Site not configured in #{SITE_CONFIG_PATH}", :red
        say "Add: Sitepress.configuration.site = Sitepress::Site.new(root_path: '.')"
        exit 1
      end
    end

    def setup_site_from_server!
      # Store the site so RailsConfiguration can use it instead of creating a default.
      # This must be set BEFORE requiring sitepress-rails.
      if Sitepress.server.respond_to?(:site)
        Sitepress.pending_site = Sitepress.server.site
      end
    end

    def initialize_rails_app!
      require_relative "application"

      Application.config.enable_site_error_reporting = false
      Application.config.enable_site_reloading = false

      Application.initialize!
    end

    def compile_assets(output_path)
      assets = Application.assets

      if defined?(Propshaft) && assets.is_a?(Propshaft::Assembly)
        FileUtils.mkdir_p(output_path)
        processor = Propshaft::Processor.new(
          load_path: assets.load_path,
          output_path: output_path,
          compilers: assets.compilers,
          manifest_path: output_path.join(".manifest.json")
        )
        processor.process
      elsif defined?(Sprockets) && assets.class.name.start_with?("Sprockets::")
        FileUtils.mkdir_p(output_path)
        manifest = Sprockets::Manifest.new(assets, output_path)
        precompile = Application.config.assets.precompile
        manifest.compile(precompile)
      else
        logger.warn "Unknown asset pipeline, skipping asset compilation"
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT).tap do |l|
        l.formatter = ->(_, _, _, msg) { "#{msg}\n" }
      end
    end
  end
end
