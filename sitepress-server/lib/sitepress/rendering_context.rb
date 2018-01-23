module Sitepress
  # Setups a rendering context with methods that are accessible to the view.
  # This is where helper methods are loaded, site, resource, etc. are exposed.
  class RenderingContext
    attr_reader :resource, :site
    alias :current_page :resource

    def initialize(resource:, site:)
      @resource = resource
      @site = site
      extend_instance_with_helpers
    end

    def render(asset = nil, locals: {}, &block)
      asset = ceorce_asset(asset || resource.asset)
      renderer = AssetRenderer.new(asset)
      renderer.render(self, **locals, &block)
    end

    private
    # Loads all of the helper modules and extends the instance of the
    # `RenderingContext`. This makes all of the helpers available to
    # the views.
    def extend_instance_with_helpers
      paths = Dir.glob @site.helpers_path.join("**.rb")
      HelperLoader.new(paths: paths).extend_instance(self)
    end

    # TODO: Replace this with a "fuzzy asset finder" class.
    def ceorce_asset(assetish)
      case assetish
      when String
        site.get(assetish).asset # TODO: If this is nil we should just throw an exception.
      when Asset
        assetish
      else
        raise RuntimeError, "#{assetish.inspect} cannot be coerce into Sitepress::Asset"
      end
    end
  end
end
