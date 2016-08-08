require "sitepress"
require "tilt"
require "pathname"

module Sitepress
  class TiltResourceRenderer
    def initialize(resource)
      @resource = resource
    end

    def render(locals: {}, layout: nil, &block)
      template = engine.new { @asset.body }
      with_layout layout: layout, locals: locals do
        template.render(Object.new, **locals, &block)
      end
    end

    private
    def with_layout(layout: , **args, &block)
      if layout
        layout_renderer = TiltRenderer.new(layout)
        layout_renderer.render **args, &block
      else
        block.call
      end
    end

    def engine
      Tilt[@asset.path]
    end
  end

  # Mount inside of a config.ru file to run this as a server.
  class Server
    def initialize(sitemap: )
      @sitemap = sitemap
    end

    def call(env)
      req = Rack::Request.new(env)
      resource = @sitemap.get req.path
      if resource
        # TODO: Memoize this between requests.
        resources = @sitemap.resources
        body = if resource.asset.template_extensions.any?
          renderer = TiltRenderer.new(resource.asset)
          layout = resource.data.has_key?("layout") ? Asset.new(path: resource.data["layout"]) : nil
          renderer.render(layout: layout, locals: {
            resources: resources,
            resource: resource
          })
        else
          resource.body
        end

        mime_type = resource.mime_type.to_s

        [ 200, {"Content-Type" => mime_type}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
