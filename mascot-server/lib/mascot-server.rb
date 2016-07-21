require "mascot"

module Mascot
  require "tilt"

  class TiltRenderer
    def initialize(resource)
      @resource = resource
    end

    def render
      template = engine.new { |t| @resource.body }
      template.render(Object.new, @resource.locals)
    end

    private
    def engine
      Tilt[@resource.file_path]
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
      if resource = @sitemap.find_by_request_path(normalize_path(req.path))
        [ 200, {"Content-Type" => resource.mime_type.to_s}, [TiltRenderer.new(resource).render] ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end

    private
    # If we mount this middleware in a path other than root, we need to configure it
    # so that it correctly maps the request path to the content path.
    def normalize_path(request_path)
      ROOT_PATH.join(Pathname.new(request_path).relative_path_from(@relative_to)).to_s
    end
  end
end
