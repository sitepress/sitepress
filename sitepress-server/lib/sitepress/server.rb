require "async"
require "async/http/endpoint"
require "console"
require "falcon"
require "protocol/rack/adapter"

module Sitepress
  # Development server using Falcon with process supervision and optional reloading.
  #
  # Example:
  #   app = MyRackApp.new
  #   reloader = Sitepress::Reloader.new
  #   reloader.watch "./pages"
  #   server = Sitepress::Server.new(app, reloader: reloader)
  #   server.add_process :css, "tailwindcss -w -i ./assets/site.css -o ./public/site.css"
  #   server.run
  #
  class Server
    DEFAULT_HOST = "127.0.0.1".freeze
    DEFAULT_PORT = 8080

    attr_reader :app, :processes, :reloader
    attr_accessor :host, :port

    def initialize(app, reloader: nil)
      @app = app
      @processes = []
      @reloader = reloader
      @host = DEFAULT_HOST
      @port = DEFAULT_PORT
    end

    # Add a labeled process to run alongside the server.
    def add_process(label, command)
      process = Process.new(label: label, command: command)
      @processes << process
      process
    end

    # Start the server and all configured processes.
    def run
      print_banner

      Sync do |task|
        start_processes(task)
        start_reloader(task)
        start_falcon
      end
    end

    private

    def print_banner
      # Suppress noisy EPIPE warnings when SSE clients disconnect during navigation
      Console.logger.level = :error if reloader

      puts "Sitepress server starting..."
      puts "  URL:  http://#{host}:#{port}/"
      puts "  Reloader: #{reloader ? 'enabled' : 'disabled'}"
      puts ""
    end

    def start_processes(task)
      return if @processes.empty?

      task.async do
        supervisor = ProcessSupervisor.new
        @processes.each { |p| supervisor.add(p) }
        supervisor.run
      end
    end

    def start_reloader(task)
      return unless reloader

      task.async { reloader.start_watching }
    end

    def start_falcon
      rack_app = build_rack_app
      adapted_app = Protocol::Rack::Adapter.new(rack_app)
      endpoint = Async::HTTP::Endpoint.parse("http://#{host}:#{port}/")

      server = Falcon::Server.new(adapted_app, endpoint)
      server.run.wait
    end

    def build_rack_app
      main_app = app
      r = reloader

      Rack::Builder.new do
        if r
          use r.middleware

          map "/_sitepress/changes" do
            run ->(env) { r.connect }
          end
        end

        run main_app
      end
    end
  end
end
