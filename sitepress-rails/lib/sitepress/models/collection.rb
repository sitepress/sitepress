module Sitepress
  module Models
    # Everything needed to iterate over a set of resources from a glob and wrap
    # them in a model so they are returned as a sensible enumerable.
    class Collection
      include Enumerable

      attr_reader :model

      def initialize(model:, &resources)
        @model = model
        @resources = resources
      end

      def resources
        @resources.call
      end

      # Wraps each resource in a model object.
      def each(&block)
        return to_enum(:each) unless block_given?

        resources.each do |resource|
          yield model.new(resource)
        end
      end
    end
  end
end
