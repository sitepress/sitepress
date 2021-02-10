module Sitepress
  module Renderers
    class Server
      attr_reader :rails_app, :page

      def initialize(page, rails_app = Sitepress::Server)
        @rails_app = rails_app
        @page = page
        rails_app.boot
      end

      def compile
        code, headers, response = rails_app.routes.call env
        response.body
      end

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
