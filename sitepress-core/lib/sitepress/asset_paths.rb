require "pathname"

module Sitepress
  # Iterates through a folder, ignores partials and files that are well known to
  # not be part of the website files, like `.DS_Store`, etc.
  class AssetPaths
    include Enumerable

    # Exclude swap files created by Textmate and vim from being added
    # to the sitemap.
    IGNORE_FILE_PATTERNS = [
      "*~",         # Created by many editors when things crash
      "*.swp",      # Created by vim
      ".DS_Store",  # Created by our friends at Apple
      "*.orig"      # Created when there's a git conflict
    ]

    # Template files that start with `_user.html.erb` are partials that we want
    # to ignore for the site's navigation tree.
    PARTIAL_PREFIX = "_".freeze

    attr_reader :path

    def initialize(path:)
      @path = Pathname.new(path)
    end

    # Returns a list of files, paths, and node names to iterate through to build out nodes
    def each
      path.each_child do |path|
        yield path unless ignore_file? path
      end
    end

    private

    def ignore_file?(path)
      is_partial_file?(path) or matches_ignore_file_pattern?(path)
    end

    def is_partial_file?(path)
      path.basename.to_s.start_with? PARTIAL_PREFIX
    end

    def matches_ignore_file_pattern?(path)
      IGNORE_FILE_PATTERNS.any? { |pattern| path.basename.fnmatch? pattern }
    end
  end
end
