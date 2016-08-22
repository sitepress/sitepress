module Mascot
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class DirectoryCollection
    attr_reader :assets, :path

    def initialize(path: , assets:)
      @path = path
      @assets = assets
    end

    def mount(node)
      assets.each { |a| node.add path: asset_path_to_request_path(a), asset: a }
    end

    private
    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def asset_path_to_request_path(asset)
      # Relative path of resource to the file_path of this project.
      asset.path.dirname.join(asset.format_basename).relative_path_from(path).to_s
    end
  end
end
