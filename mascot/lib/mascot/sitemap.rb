require "pathname"

module Mascot
  # A collection of pages from a directory.
  class Sitemap
    # Default file pattern to pick up in sitemap
    DEFAULT_GLOB = "**/**".freeze
    # Default root path for sitemap.
    DEFAULT_ROOT_DIR = Pathname.new(".").freeze
    # Default root request path
    DEFAULT_ROOT_REQUEST_PATH = Pathname.new("/").freeze

    attr_reader :file_path, :request_path

    def initialize(file_path: DEFAULT_ROOT_DIR, request_path: DEFAULT_ROOT_REQUEST_PATH)
      self.file_path = file_path
      self.request_path = request_path
    end

    # Lazy stream of files that are to be rendered.
    def assets(glob = DEFAULT_GLOB)
      Dir[validate_path(file_path.join(glob))].select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    def resources(glob = DEFAULT_GLOB)
      assets(glob).lazy.map do |asset|
        Resource.new request_path: format_request_path(asset.path), asset: asset
      end
    end

    # Find the page with a path.
    def find_by_request_path(request_path)
      return if request_path.nil?
      resources.find { |r| r.request_path == File.join("/", request_path) }
    end

    def file_path=(path)
      @file_path = Pathname.new(path)
    end

    def request_path=(path)
      @request_path = Pathname.new(path)
    end

    private

    # Make sure the user is accessing a file within the root path of the
    # sitemap.
    def validate_path(path)
      root_path = @file_path.expand_path.to_s
      resource_path = path.expand_path.to_s

      if resource_path.start_with? root_path
        path
      else
        raise Mascot::InsecurePathAccessError, "#{resource_path} outside sitemap #{root_path} directory"
      end
    end

    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def format_request_path(path)
      # Relative path of resource to the file_path of this project.
      relative_path = Pathname.new(path).relative_path_from(@file_path)
      # Removes the .fooz.baz
      @request_path.join(relative_path).to_s.sub(/\..*/, '')
    end
  end
end
