module Sitepress
  # Maps a directory of assets into a set of routes that correspond with
  # the `path` root.
  class SourceNodeMapper
    DEFAULT_BASENAME = "index".freeze
    DEFAULT_FORMAT = "html".freeze

    attr_reader :assets, :path

    def initialize(path:, assets:)
      @path = path
      @assets = assets
    end

    def mount(node)
      assets.each do |asset|
        # TODO: Remove the to_s and handle the "root" situation more intelligently.
        path = asset_path_to_request_path(asset).to_s
        if path == "." # Root path
          # require "pry"
          # binding.pry
          node.formats.add(asset: asset)
        else
          node.add path: path, asset: asset
        end
      end
    end

    private
    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def asset_path_to_request_path(asset)
      # If we come across `/index.html`, then return `./`
      if asset.format_extension == DEFAULT_FORMAT and asset.basename == DEFAULT_BASENAME
        asset.path.dirname.relative_path_from(path)
      # If we come across `/foo/bar.html.erb`, then return `./foo/bar`
      elsif asset.format_extension == DEFAULT_FORMAT
        asset.path.dirname.join(asset.basename).relative_path_from(path)
      # If we come across `/fiz/buz.jpg`, then return `./fiz/buz.jpg`
      else
        # Relative path of resource to the file_path of this project.
        asset.path.dirname.join(asset.format_basename).relative_path_from(path)
      end
    end
  end
end
