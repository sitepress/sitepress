require "sitepress"
require "tilt"
require "pathname"
require "fileutils"

module Sitepress
  class AssetRenderer
    def initialize(asset)
      @asset = asset
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
        layout_renderer = AssetRenderer.new(layout)
        layout_renderer.render **args, &block
      else
        block.call
      end
    end

    def engine
      Tilt[@asset.path]
    end
  end

  # Renders a resource
  class ResourceRenderer
    def initialize(resource:)
      @resource = resource
    end

    def render(locals: {})
      if renderable_resource?
        renderer.render layout: layout,
          locals: locals.merge(resource: @resource)
      else
        @resource.body
      end
    end

    private
    # TODO: Add layout_path to Site#layout_path.
    def layout
      @resource.data.has_key?("layout") ? Asset.new(path: @resource.data["layout"]) : nil
    end

    def renderer
      AssetRenderer.new(@resource.asset)
    end

    def renderable_resource?
      @resource.asset.template_extensions.any?
    end
  end

  class Compiler
    def initialize(site: )
      @site = site
    end

    # Iterates through all pages and writes them to disk
    def compile(target_path:)
      target_path = Pathname.new(target_path)
      # TODO: Should file operations go here? Probably not.
      FileUtils::mkdir_p target_path
      root = Pathname.new("/")
      puts "Compiling #{@site.root_path.expand_path}"
      @site.resources.each do |resource|
        # These are root `resource.request_path`
        derooted = Pathname.new(resource.request_path).relative_path_from(root)
        path = target_path.join(derooted)
        FileUtils::mkdir_p path.dirname
        puts "  #{path}"
        File.open(path.expand_path, "w"){ |f| f.write render(resource) }
      end
      puts "Successful compilation to #{target_path.expand_path}"
    end

    private
    def render(resource)
      ResourceRenderer.new(resource: resource).render(locals: {resources: @site.resources})
    end
  end

  # Mount inside of a config.ru file to run this as a server.
  class Server
    def initialize(site: )
      @site = site
    end

    def call(env)
      req = Rack::Request.new(env)
      resource = @site.get req.path
      if resource
        mime_type = resource.mime_type.to_s
        renderer = ResourceRenderer.new resource: resource
        body = renderer.render locals: {resources: @site.resources}
        [ 200, {"Content-Type" => mime_type}, Array(body) ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
