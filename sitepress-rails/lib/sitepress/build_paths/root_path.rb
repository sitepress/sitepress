module Sitepress
  module BuildPaths
    # Compiles pages directly from `/pages/blah.html.haml` to `/blah.html`. Handles root `index`
    # pages too, mainly grabbing the root, which doesn't have a name in the node, to the default_name
    # of the node, which is usually `index`.
    class RootPath
      attr_reader :resource

      extend Forwardable
      def_delegators :resource, :node, :format

      def initialize(resource)
        @resource = resource
      end

      def filename
        if format.nil?
          filename_without_format
        elsif format == node.default_format
          filename_with_default_format
        elsif format
          filename_with_format
        end
      end

      def path
        File.join(*resource.lineage, filename)
      end

      protected
      def filename_without_format
        node.default_name
      end

      def filename_with_format
        "#{node.default_name}.#{format}"
      end

      def filename_with_default_format
        filename_with_format
      end
    end
  end
end
