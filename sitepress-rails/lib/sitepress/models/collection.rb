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

      attr_reader :model, :glob, :site

      def initialize(model:, site:, glob: DEFAULT_GLOB)
        @model = model
        @glob = glob
        @site = site
      end

      def resources
        site.glob glob
      end

      # Wraps each resource in a model object.
      def each
        resources.each do |resource|
          yield model.new resource
        end
      end
    end
  end
end
