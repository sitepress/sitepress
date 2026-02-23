require "listen"

module Sitepress
  # Manages browser reloading: SSE client connections and file watching.
  class Reloader
    attr_reader :watch_paths
    attr_accessor :logger

    def initialize(logger: nil)
      @clients = {}
      @next_client_id = 0
      @watch_paths = []
      @listener = nil
      @logger = logger
    end

    # Add a path to watch for changes.
    def watch(path)
      @watch_paths << path.to_s
    end

    # Create an SSE connection for a client.
    # Returns a Rack response tuple.
    def connect
      client_id = @next_client_id += 1
      body = SSEConnection.new(client_id, @clients)
      [200, sse_headers, body]
    end

    # Notify all connected clients to reload.
    def notify(modified: [], added: [], removed: [])
      log "Files changed at #{Time.now}"
      modified.each { |f| log "  Modified #{f}" }
      added.each { |f| log "  Added #{f}" }
      removed.each { |f| log "  Removed #{f}" }
      log "Reloading #{@clients.size} client(s)"
      log ""
      log ""

      @clients.each_value do |queue|
        queue << "event: change\ndata: \n\n" rescue nil
      end
    end

    # Start watching files for changes.
    # Call this within an Async task.
    def start_watching
      paths = @watch_paths.select { |p| File.directory?(p) }
      return if paths.empty?

      log "Reloader watching"

      @listener = Listen.to(*paths) do |modified, added, removed|
        notify(modified: modified, added: added, removed: removed)
      end

      @listener.start
      sleep # Keep the task alive
    end

    # Stop watching files.
    def stop_watching
      @listener&.stop
    end

    # Returns a Rack middleware that injects the reload script.
    def middleware
      Middleware
    end

    private

    def log(message)
      @logger&.puts message
    end

    def sse_headers
      {
        "Content-Type" => "text/event-stream",
        "Cache-Control" => "no-cache"
      }
    end

    # SSE response body that yields messages from a queue.
    class SSEConnection
      def initialize(client_id, clients)
        @client_id = client_id
        @clients = clients
        @queue = Queue.new
      end

      def each
        @clients[@client_id] = @queue
        yield "data: connected\n\n"

        loop do
          msg = @queue.pop
          break if msg == :close
          yield msg
        end
      rescue Errno::EPIPE, IOError
        # Client disconnected
      ensure
        @clients.delete(@client_id)
      end

      def close
        @queue << :close rescue nil
      end
    end

    # Rack middleware that injects reload script into HTML responses.
    class Middleware
      SCRIPT = <<~HTML
        <script>
          (function() {
            var es = new EventSource("/_sitepress/changes");
            es.addEventListener("change", function() { location.reload(); });
          })();
        </script>
      HTML

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if html_response?(headers)
          body = inject_script(body)
        end

        [status, headers, body]
      end

      private

      def html_response?(headers)
        content_type = headers["Content-Type"] || headers["content-type"] || ""
        content_type.include?("text/html")
      end

      def inject_script(body)
        html = +""
        body.each { |chunk| html << chunk }
        body.close if body.respond_to?(:close)

        if html.include?("</body>")
          html.sub!("</body>", "#{SCRIPT}</body>")
        else
          html << SCRIPT
        end

        [html]
      end
    end
  end
end
