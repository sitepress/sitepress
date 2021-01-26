module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class SourceNodeMapper
    DEFAULT_BASENAME = "index".freeze
    DEFAULT_FORMAT = "html".freeze

    # TODO: Move this into the SoureNodeMapper class so that its not
    # a concern of site.rb
    # Exclude swap files created by Textmate and vim from being added
    # to the sitemap.
    SWAP_FILE_EXTENSIONS = [
      "~",
      ".swp"
    ]

    attr_reader :assets, :path
    alias :root :path

    def initialize(path:)
      @path = path
    end

    def mount(node)
      root.each_child do |path|
        next if is_swap_file? path

        node_name, node_format, template_handler = path.basename.to_s.split(".")
        child_node = node.build_child(node_name)

        if path.directory?
          SourceNodeMapper.new(path: path).mount(child_node)
        else
          asset = Asset.new(path: path)

          if node_format == DEFAULT_FORMAT and node_name == DEFAULT_BASENAME
            node.formats.add(asset: asset)
          elsif node_format == DEFAULT_FORMAT
            child_node.formats.add(asset: asset)
          else
            child_node.formats.add(asset: asset, ext: ".#{node_format}")
          end
        end
      end
    end

    private
    def is_swap_file?(path)
      SWAP_FILE_EXTENSIONS.any? { |ext| path.to_s.end_with? ext }
    end
  end
end
