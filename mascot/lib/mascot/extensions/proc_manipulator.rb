module Mascot
  module Extensions
    class ProcManipulator
      def initialize(block)
        @block = block
      end

      def process_resources(resources)
        resources.each do |resource|
          if @block.arity == 1
            @block.call resource
          else # This will blow up if 0 or greater than 2.
            @block.call resource, resources
          end
        end
      end
    end
  end
end
