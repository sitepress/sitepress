module Sitepress
  # Maps a tree of Directory and Asset objects into a tree of nodes that
  # form the navigational structure of a website. You can override this
  # in a site to deal with different file systems. For example, Notion
  # has a completely different file structure for its content than Rails, so
  # we could extend this class to properly map those differences into a tree
  # of nodes.
  class AssetNodeMapper
    attr_reader :asset_paths

    def initialize(path)
      @asset_paths = AssetPaths.new(path: path)
    end

    # Maps the source files from the path into the given node.
    def map(node)
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
      self.class.new(path).map(node.child(node_name))
    end

    def process_asset(path, node)
      asset = Page.new(path: path)
      node.child(asset.node_name).resources.add_asset(asset, format: asset.format)
    end
  end
end
