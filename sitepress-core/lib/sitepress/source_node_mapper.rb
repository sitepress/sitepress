module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class SourceNodeMapper
    # Exclude swap files created by Textmate and vim from being added
    # to the sitemap.
    SWAP_FILE_EXTENSIONS = [
      "~",
      ".swp",
      ".DS_Store" # TODO: Not a swap file, but something that should be ignored.
    ]

    # Partial rails prefix.
    PARTIAL_PREFIX = "_".freeze

    attr_reader :assets, :path
    alias :root :path

    def initialize(path:)
      @path = path
    end

    # Mounts the source files from the path to the given node.
    def mount(node)
      paths.each do |path, name, format|
        if path.directory?
          SourceNodeMapper.new(path: path).mount node.add_child(name)
        else
          asset = Asset.new(path: path)
          node.add_child(name).formats.add(format: format, asset: asset)
        end
      end
    end

    private
    # Returns a list of files, paths, and node names to iterate through to build out nodes
    def paths
      Enumerator.new do |y|
        root.each_child do |path|
          next if is_swap_file? path
          next if is_partial_file? path

          node_name, node_format, template_handler = path.basename.to_s.split(".")
          y << [ path, node_name, node_format&.to_sym ]
        end
      end
    end

    def is_partial_file?(path)
      path.basename.to_s.start_with? PARTIAL_PREFIX
    end

    def is_swap_file?(path)
      SWAP_FILE_EXTENSIONS.any? { |ext| path.to_s.end_with? ext }
    end
  end
end
