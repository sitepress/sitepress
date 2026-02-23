module Sitepress
  # Development server wrapper that handles Application setup and
  # delegates to the base Server class.
  #
  # This provides a simpler API for site.rb configuration:
  #
  #   site = Sitepress::Site.new(root_path: ".")
  #   Sitepress.server = Sitepress::ApplicationServer.new(site)
  #   Sitepress.server.live_reload = true
  #   Sitepress.server.add_process :css, "tailwindcss -w ..."
  #
  class ApplicationServer
    attr_reader :site, :processes
    attr_accessor :live_reload, :host, :port

    def initialize(site)
      @site = site
      @live_reload = false
      @host = Server::DEFAULT_HOST
      @port = Server::DEFAULT_PORT
      @processes = []
    end

    # Add a labeled process to run alongside the server.
    def add_process(label, command)
      @processes << [label, command]
    end

    # Start the server with the Sitepress Application.
    def run
      setup_application!

      r = build_reloader if live_reload

      server = Server.new(Application, reloader: r)
      server.host = host
      server.port = port
      @processes.each { |label, cmd| server.add_process(label, cmd) }

      puts "  Site: #{site.root_path}"
      server.run
    end

    private

    def setup_application!
      require_relative "application"

      Application.config.enable_site_error_reporting = true
      Application.config.enable_site_reloading = true

      # Make site available to the Rails app
      Sitepress.configuration.site = site

      Application.initialize!
    end

    def build_reloader
      r = Reloader.new(logger: $stdout)
      site_watch_paths.each { |path| r.watch(path) }
      r
    end

    def site_watch_paths
      [
        site.pages_path.to_s,
        site.helpers_path.to_s,
        site.assets_path.to_s
      ].select { |p| File.directory?(p) }
    end
  end
end
