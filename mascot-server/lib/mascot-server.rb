require "mascot"
require "tilt"

module Mascot
  class TiltRenderer
    def initialize(resource)
      @resource = resource
    end

    def render
      template = engine.new { @resource.body }
      template.render(Object.new, {current_page: @resource})
    end

    private
    def engine
      Tilt[@resource.asset.path]
    end
  end

  # Mount inside of a config.ru file to run this as a server.
  class Server
    ROOT_PATH = Pathname.new("/")

    def initialize(sitemap: , relative_to: "/")
      @relative_to = Pathname.new(relative_to)
      @sitemap = sitemap
    end

    def call(env)
      req = Rack::Request.new(env)
      resource = @sitemap.get req.path

      if  resource
        [ 200, {"Content-Type" => resource.mime_type.to_s}, [TiltRenderer.new(resource).render] ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
