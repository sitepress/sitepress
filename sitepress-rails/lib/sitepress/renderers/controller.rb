module Sitepress
  module Renderers
    # This would be the ideal way to render Sitepress resources, but there's a lot
    # of hackery involved in getting it to work properly.
    class Controller
      attr_reader :controller, :resource

      def initialize(resource, controller = SiteController)
        @controller = controller
        @resource = resource
      end

      def render
        renderer.render inline: resource.body,
          type: resource.asset.template_extensions.last,
          layout: resolve_layout,
          content_type: resource.mime_type.to_s
      end

      private
        def layout
          controller._layout
        end

        def has_layout_conditions?
          controller._layout_conditions?
        end

        def layout_conditions
          controller._layout_conditions
        end

        def renderer
          controller.renderer.new("PATH_INFO" => resource.request_path)
        end

        def resolve_layout
          return resource.data.fetch("layout") if resource.data.key? "layout"
          return layout unless has_layout_conditions?

          clause, formats = layout_conditions.first
          format = resource.format.to_s

          case clause
          when :only
            layout if formats.include? format
          when :except
            layout if formats.exclude? format
          end
        end
    end
  end
end