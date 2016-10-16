require "sitepress"
require "tilt"

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

  autoload :Compiler,     "sitepress/compiler"
  autoload :HelperLoader, "sitepress/helper_loader"
  autoload :Server,       "sitepress/server"
end
