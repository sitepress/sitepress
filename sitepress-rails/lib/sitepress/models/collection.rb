module Sitepress
  module Models
    # Everything needed to iterate over a set of resources from a glob and wrap
    # them in a model so they are returned as a sensible enumerable.
    class Collection
      include Enumerable

      # Page models will have `PageModel.all` method defined by default.
      DEFAULT_NAME = :all

      # Iterate over all resources in the site by default.
      DEFAULT_GLOB = "**/*.*".freeze

      attr_reader :model, :glob, :site, :sort

      def initialize(model:, site:, glob: DEFAULT_GLOB, sort: nil)
        @model = model
        @glob = glob
        @site = site
        @sort = sort
      end

      def resources
        return unsorted_resources unless sort

        unsorted_resources.sort_by { |resource| resource.data.try(:[], @sort) }
      end

      # Wraps each resource in a model object.
      def each
        resources.each do |resource|
          yield model.new resource
        end
      end

      private

      def unsorted_resources
        site.glob(glob)
      end
    end
  end
end
