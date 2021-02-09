module Sitepress
  class ServerCompiler
    attr_reader :rails_app, :page

    def initialize(page, rails_app = Sitepress::Server)
      @rails_app = rails_app
      @page = page
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
