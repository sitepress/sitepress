module Sitepress
  module Renderers
    # Renders pages by invoking a rack call to the Rails application. From my
    # experiments rendering as of 2021, this is the most reliable way to render
    # pages. Rendering via `Renderers::Controller` has lots of various subtle issues
    # that are surprising. People don't like surprises, so I opted to render through a
    # slightly heavier stack.
    class Server
      attr_reader :rails_app, :page

      def initialize(page, rails_app = Rails.application)
        @rails_app = rails_app
        @page = page
      end

      def render
        code, headers, response = rails_app.routes.call env
        response.body
      rescue => e
        raise Compiler::RenderingError.new "Error rendering #{page.request_path.inspect} at #{page.asset.path.expand_path.to_s.inspect}:\n#{e.message}"
      end

      private
      def env
        {
          "PATH_INFO"=> page.request_path,
          "REQUEST_METHOD"=>"GET",
          "rack.input" => "GET"
        }
      end
    end
  end
end
