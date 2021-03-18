module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class SourceNodeMapper
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
          next if ignore_file? path

          name, format, template_handler = path.basename.to_s.split(".")
          format = format.to_sym if format

          y << [ path, name, format ]
        end
      end
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
