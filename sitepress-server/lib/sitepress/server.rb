module Sitepress
  # Run a Sitepress site as a rack app.
  class Server
    def initialize(site: )
      @site = site
    end

    def call(env)
      req = Rack::Request.new(env)
      resource = @site.get req.path

      if resource
        mime_type = resource.mime_type.to_s
        context = RenderingContext.new(resource: resource, site: @site)
        body = context.render

        [ 200, {"Content-Type" => mime_type}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, not_found_message]
      end
    end

    private
      def not_found_message
        @site.resources.map(&:request_path).map{ |line| "  #{line}\n" }
          .unshift("Not Found - Try these paths instead:\n")
      end
  end
end
