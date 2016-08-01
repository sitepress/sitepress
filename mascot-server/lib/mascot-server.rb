require "mascot"
require "tilt"
require "pathname"

module Mascot
  class TiltResourceRenderer
    def initialize(resource)
      @resource = resource
    end

    def render(locals: {}, layout: "layout")
      template = engine.new { @resource.body }
      template.render(Object.new, **locals.merge(resource: @resource))
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
      # TODO: Memoize this per request and between requests eventually.
      resources = @sitemap.resources

      if resource
        body = if resource.asset.template_extensions.empty?
          # TODO: This is not efficient for huge files. Research how Rack::File
          # serves this up (or just take that, maybe mount it as a cascading middleware.)
          resource.body
        else
          TiltResourceRenderer.new(resource).render(locals: {resources: resources})
        end

        [ 200, {"Content-Type" => resource.mime_type.to_s}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
