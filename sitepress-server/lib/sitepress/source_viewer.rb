require "json"

module Sitepress
  class SourceViewer
    CONTEXT_LINES = 5

    def call(env)
      return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

      params = Rack::Utils.parse_query(env["QUERY_STRING"])
      file = params["file"]
      line = params["line"].to_i

      return bad_request("Missing file parameter") unless file
      return bad_request("Missing line parameter") unless line > 0
      return not_found("File not found") unless File.exist?(file)
      return forbidden("Access denied") unless allowed_path?(file)

      source = read_source(file, line)
      json_response(source)
    rescue => e
      error_response(e.message)
    end

    private

    def read_source(file, target_line)
      lines = File.readlines(file)
      start_line = [target_line - CONTEXT_LINES, 1].max
      end_line = [target_line + CONTEXT_LINES, lines.length].min

      source_lines = (start_line..end_line).map do |num|
        {
          number: num,
          code: lines[num - 1]&.chomp || "",
          error: num == target_line
        }
      end

      {
        file: file,
        line: target_line,
        lines: source_lines
      }
    end

    def allowed_path?(file)
      expanded = File.expand_path(file)

      # Only allow .rb and .erb files (source code)
      return false unless expanded.end_with?('.rb', '.erb', '.html.erb')

      # Block access to sensitive paths
      sensitive = %w[/etc /var /private /root]
      return false if sensitive.any? { |s| expanded.start_with?(s) }

      # Allow any readable source file in development
      File.readable?(expanded)
    end

    def json_response(data)
      [200, { "Content-Type" => "application/json" }, [JSON.generate(data)]]
    end

    def bad_request(message)
      [400, { "Content-Type" => "application/json" }, [JSON.generate({ error: message })]]
    end

    def not_found(message)
      [404, { "Content-Type" => "application/json" }, [JSON.generate({ error: message })]]
    end

    def forbidden(message)
      [403, { "Content-Type" => "application/json" }, [JSON.generate({ error: message })]]
    end

    def method_not_allowed
      [405, { "Content-Type" => "application/json" }, [JSON.generate({ error: "Method not allowed" })]]
    end

    def error_response(message)
      [500, { "Content-Type" => "application/json" }, [JSON.generate({ error: message })]]
    end
  end
end
