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
        # TODO: Lets slim this down a bit.
        helpers = HelperLoader.new paths: Dir.glob(@site.root_path.join("helpers/**.rb"))
        context = helpers.context(locals: { current_page: resource, site: @site })

        mime_type = resource.mime_type.to_s
        renderer = ResourceRenderer.new resource: resource
        # TODO: Remove locals from this chain. Don't need 'em!
        body = renderer.render context: context

        [ 200, {"Content-Type" => mime_type}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
