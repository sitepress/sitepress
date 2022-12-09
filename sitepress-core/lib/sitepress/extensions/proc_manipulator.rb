module Sitepress
  module Extensions
    class ProcManipulator
      def initialize(block)
        @block = block
      end

      def process_resources(node)
        @block.call node
      end
    end
  end
end
