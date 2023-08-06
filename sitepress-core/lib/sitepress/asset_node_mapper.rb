module Sitepress
  # Maps a tree of Directory and Asset objects in a a tree of nodes that
  # format the navigational structure of a website. You can override this
  # this in a site to deal with different file systems. For example, Notion
  # has a completely different file structure for its content than Rails, so
  # we could extend this class to properly map those differences into a tree
  # of nodes.
  class AssetNodeMapper
    attr_reader :node, :asset_paths

    def initialize(path:, node:)
      @asset_paths = AssetPaths.new(path: path)
      @node = node
    end

    # Mounts the source files from the path to the given node.
    def map
      asset_paths.each do |path|
        if path.directory?
          process_directory path
        else
          process_asset path
        end
      end
    end

    protected

    def process_directory(path)
      node_name = File.basename path
      node_mapper path: path, node: node.child(node_name)
    end

    def process_asset(path)
      asset = Asset.new(path: path)
      node.child(asset.node_name).resources.add_asset(asset, format: asset.format)
    end

    private

    def node_mapper(*args, **kwargs)
      self.class.new(*args, **kwargs).map
    end
  end
end
