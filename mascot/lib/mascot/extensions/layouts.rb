module Mascot
  module Extensions
    # Register layouts with resources that match certain patterns.
    class Layouts
      Rule = Struct.new(:layout, :processor)

      def initialize
        @rules = Array.new
      end

      # Register a layout for a set of resources.
      def layout(layout, &block)
        @rules << Rule.new(layout, block)
      end

      def process_resources(node)
        node.resources.each do |resource|
          @rules.each do |rule|
            if rule.processor.call(resource)
              resource.data["layout"] ||= rule.layout
            end
          end
        end
      end
    end
  end
end
