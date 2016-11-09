require "tilt"

module Sitepress
  # Since we use Frontmatter, we have to do some parsing to
  # get a Tilt template working properly.
  class AssetTemplate
    attr_reader :asset

    def initialize(asset)
      @asset = ceorce_asset(asset)
    end

    def render(*args, &block)
      if renderable_resource?
        template.render(*args, &block)
      else
        asset.body
      end
    end

    def template
      @_template ||= engine.new{ asset.body }
    end

    private
    def renderable_resource?
      asset.template_extensions.any?
    end

    def engine
      @_engine ||= Tilt[asset.path]
    end

    # TODO: Replace this with a "fuzzy asset finder"
    def ceorce_asset(assetish)
      case assetish
      when String
        Asset.new(path: assetish)
      when Asset
        assetish
      else
        raise RuntimeError, "#{assetish.inspect} cannot be coerce into Sitepress::Asset"
      end
    end
  end
end