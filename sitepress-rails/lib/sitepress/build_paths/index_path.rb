module Sitepress
  module BuildPaths
    # Compiles pages directly from `/pages/blah.html.haml` to `/blah.html`. Handles root `index`
    # pages too, mainly grabbing the root, which doesn't have a name in the node, to the default_name
    # of the node, which is usually `index`.
    class IndexPath < RootPath
      def path_without_format
        node.name
      end

      def path_with_format
        "#{node.name}.#{format}"
      end

      def path_with_default_format
        path_with_format
      end
    end
  end
end
