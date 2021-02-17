module Sitepress
  module BuildPaths
    # In many cases, you'll want to serve up `pages/blah.html.haml` as `/blah` on
    # hosts like S3. To achieve this effect, we have to compile `pages/blah.html.haml`
    # to a folder with the filename `index.html`, so the final path would be `/blah/index.html`
    class DirectoryIndexPath < IndexPath
      def path_with_default_format
        File.join(node.name, "#{node.default_name}.#{format}")
      end
    end
  end
end
