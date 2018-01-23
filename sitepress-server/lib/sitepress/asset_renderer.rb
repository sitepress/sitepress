require "tilt"

module Sitepress
  # Since we use Frontmatter, we have to do some parsing to
  # get a Tilt template working properly.
  class AssetRenderer
    attr_reader :asset

    def initialize(asset)
      @asset = asset
    end

    def render(context, locals: {}, &content)
      if renderable_resource?
        template.render(context, **locals, &content)
      else
        asset.body
      end
    end

    private
      # TODO: This would fail for file formats like `.tar.gz` by assuming
      # that `gz` is a renderable format. Best place to fix this problem
      # would be in the `template_extensions` method itself.
      def renderable_resource?
        asset.template_extensions.any?
      end

      def template
        @_template ||= engine.new{ asset.body }
      end

      def engine
        @_engine ||= Tilt[asset.path]
      end
  end
end