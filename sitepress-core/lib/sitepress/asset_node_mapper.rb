module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class AssetNodeMapper
    # Exclude swap files created by Textmate and vim from being added
    # to the sitemap.
    IGNORE_FILE_PATTERNS = [
      "*~",         # Created by many editors when things crash
      "*.swp",      # Created by vim
      ".DS_Store",  # Created by our friends at Apple
      "*.orig"      # Created when there's a git conflict
    ]

    # Partial rails prefix.
    PARTIAL_PREFIX = "_".freeze

    attr_reader :assets, :path, :node
    alias :root :path

    def initialize(path:, node:)
      @path = path
      @node = node
    end

    # Mounts the source files from the path to the given node.
    def map
      paths.each do |path|
        if path.directory?
          process_directory path
        else
          process_asset Asset.new(path: path)
        end
      end
    end

    protected

    def process_directory(path)
      name = File.basename path
      node_mapper path: path, node: node.add_child(name)
    end

    def process_asset(asset)
      node.add_child(asset.node_name).formats.add(format: asset.format, asset: asset)
    end

    private

    # Returns a list of files, paths, and node names to iterate through to build out nodes
    def paths
      Enumerator.new do |y|
        root.each_child do |path|
          next if ignore_file? path
          y << path
        end
      end
    end

    def node_mapper(*args, **kwargs)
      self.class.new(*args, **kwargs).map
    end

    def ignore_file?(path)
      is_partial_file?(path) or matches_ignore_file_pattern?(path)
    end

    def is_partial_file?(path)
      path.basename.to_s.start_with? PARTIAL_PREFIX
    end

    def matches_ignore_file_pattern?(path)
      IGNORE_FILE_PATTERNS.any? { |pattern| path.fnmatch? pattern }
    end
  end
end
