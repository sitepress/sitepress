module Sitepress
  module Renderers
    class Controller
      attr_reader :controller, :page

      def initialize(page, controller = SiteController)
        @controller = controller
        @page = page
      end

      def compile
        renderer.render inline: page.body,
          type: page.asset.template_extensions.last,
          layout: resolve_layout,
          content_type: page.mime_type.to_s
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
          controller.renderer.new("PATH_INFO" => page.request_path)
        end

        def resolve_layout
          return page.data.fetch("layout") if page.data.key? "layout"
          return layout unless has_layout_conditions?

          clause, formats = layout_conditions.first
          format = page.format.to_s

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