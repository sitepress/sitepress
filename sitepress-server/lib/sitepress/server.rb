module Sitepress
  # Run a Sitepress site as a rack app.
  class Server
    def initialize(site: )
      @site = site
      # TODO: This is in the wrong place. Needs to be configurable by
      # Sitepress::Site.
      @helper_paths = Dir.glob(@site.root_path.join("helpers/**.rb"))
    end

    def call(env)
      req = Rack::Request.new(env)
      resource = @site.get req.path

      if resource
        # TODO: Lets slim this down a bit.
        helpers = HelperLoader.new paths: @helper_paths
        context = helpers.context locals: {
          current_page: resource, site: @site }
        renderer = ResourceRenderer.new resource: resource

        mime_type = resource.mime_type.to_s
        body = renderer.render context: context

        [ 200, {"Content-Type" => mime_type}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
