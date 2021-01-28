module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class SourceNodeMapper
    DEFAULT_BASENAME = "index".freeze
    DEFAULT_FORMAT = :html

    # Exclude swap files created by Textmate and vim from being added
    # to the sitemap.
    SWAP_FILE_EXTENSIONS = [
      "~",
      ".swp"
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
        child_node = node.build_child(name)

        if path.directory?
          SourceNodeMapper.new(path: path).mount(child_node)
        else
          asset = Asset.new(path: path)

          if format == DEFAULT_FORMAT and name == DEFAULT_BASENAME
            node.formats.add(asset: asset)
          elsif format == DEFAULT_FORMAT
            child_node.formats.add(asset: asset)
          else
            child_node.formats.add(ext: ".#{format}", asset: asset)
          end
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
