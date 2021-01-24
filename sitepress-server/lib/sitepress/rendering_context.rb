module Sitepress
  # TODO: We're starting to get too many rendering contexts ... and this
  # won't quite fit in with the Tilt rendering context. We'll want to merge
  # this and support `capture` so that we can get `wrap_layout` working.
  class RenderingContext
    attr_reader :resource, :site
    alias :current_page :resource

    def initialize(resource:, site:)
      @resource = resource
      @site = site
      # TODO: Remove this from RenderingContext ... it should build
      load_helpers
    end

    def render(layout: nil, locals: {}, &block)
      layout ||= resource.data["layout"]
      render_with_layout(layout) { renderer.render(self, **locals, &block) }
    end

    private
    def render_with_layout(path, &block)
      if path
        template = AssetTemplate.new(path)
        template.render(self, &block)
      else
        block.call
      end
    end

    def renderer
      @_renderer ||= AssetTemplate.new(resource.asset)
    end

    # TODO: This might be accessible from the rendering scope, which wouldn't be good.
    # Figure out if this needs to be removed.
    def load_helpers
      HelperLoader.new(paths: helper_paths).extend_instance(self)
    end

    def helper_paths
      Dir.glob @site.helpers_path.join("**.rb")
    end
  end
end