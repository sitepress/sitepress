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

      def path
        if format.nil?
          path_without_format
        elsif format == node.default_format
          path_with_default_format
        elsif format
          path_with_format
        end
      end

      protected
      def path_without_format
        node.default_name
      end

      def path_with_format
        "#{node.default_name}.#{format}"
      end

      def path_with_default_format
        path_with_format
      end
    end
  end
end
