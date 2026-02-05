module Sitepress
  # Maps a directory of files into a tree of nodes that form the navigational
  # structure of a website. You can subclass this to handle different file
  # types or directory structures.
  class Directory
    attr_reader :asset_paths

    def initialize(path)
      @asset_paths = AssetPaths.new(path: path)
    end

    # Mounts the source files from the path into the given node.
    def mount(node)
      asset_paths.each do |path|
        if path.directory?
          process_directory path, node
        else
          process_asset path, node
        end
      end
    end

    protected

    def process_directory(path, node)
      node_name = File.basename path
      self.class.new(path).mount(node.child(node_name))
    end

    def process_asset(path, node)
      asset = Page.new(path: path)
      node.child(asset.node_name).resources.add_asset(asset, format: asset.format)
    end
  end

  # Backwards compatibility
  AssetNodeMapper = Directory
end
