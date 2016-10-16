require "sitepress"
require "tilt"
require "pathname"
require "fileutils"

module Sitepress
  class AssetRenderer
    def initialize(asset)
      @asset = asset
    end

    def render(locals: {}, layout: nil, context: , &block)
      template = engine.new { @asset.body }
      with_layout layout: layout, context: context do
        template.render(context, **locals, &block)
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

    def render(context: )
      if renderable_resource?
        renderer.render layout: layout, context: context
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
      # TODO: Lets slim this down a bit.
      helpers = HelperLoader.new paths: Dir.glob(@site.root_path.join("helpers/**.rb"))
      context = helpers.context(locals: { current_page: resource, site: @site })
      ResourceRenderer.new(resource: resource).render(context: context)
    end
  end

  # Loads modules into an isolated namespace that will be
  # used for the rendering context. This loader is designed to
  # be immutable so that it throws away the constants and modules
  # on each load.
  class HelperLoader
    def initialize(paths:)
      @paths = Array(paths)
    end

    def context(locals: {})
      modules = helpers
      Object.new.tap do |object|
        modules.constants.each do |module_name|
          locals.each do |name, value|
            object.define_singleton_method(name) { value }
          end
          object.send(:extend, modules.const_get(module_name))
        end
      end
    end

    private
    def helpers
      Module.new.tap do |m|
        @paths.each do |path|
          m.module_eval File.read(path)
        end
      end
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
