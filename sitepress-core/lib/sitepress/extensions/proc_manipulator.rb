module Sitepress
  module Extensions
    class ProcManipulator
      def initialize(block)
        @block = block
      end

      def process_resources(node)
        node.flatten.each do |resource|
          if @block.arity == 1
            @block.call resource
          else # This will blow up if 0 or greater than 2.
            @block.call resource, node
          end
        end
      end
    end
  end
end
