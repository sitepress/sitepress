module Sitepress
  module BuildPaths
    # Compiles pages directly from `/pages/blah.html.haml` to `/blah.html`. Handles root `index`
    # pages too, mainly grabbing the root, which doesn't have a name in the node, to the default_name
    # of the node, which is usually `index`.
    class IndexPath < RootPath
      def filename_without_format
        node.name
      end

      def filename_with_format
        "#{node.name}.#{format}"
      end

      def filename_with_default_format
        filename_with_format
      end
    end
  end
end
