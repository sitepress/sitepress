require "mime/types"

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
      source = source_for(path)
      # Parse the path to get node_name and format for tree building
      parsed_path = Path.new(path.to_s)
      node.child(parsed_path.node_name).resources.add_asset(source, format: parsed_path.format)
    end

    def source_for(path)
      mime = MIME::Types.type_for(path.to_s).first&.content_type

      case mime
      when *Image.mime_types
        Image.new(path: path)
      when *Page.mime_types, nil
        # nil handles template files like .erb that have no MIME type
        Page.new(path: path)
      else
        Static.new(path: path)
      end
    end
  end

  # Backwards compatibility
  AssetNodeMapper = Directory
end
