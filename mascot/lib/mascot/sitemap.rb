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

    attr_reader :root_dir, :request_path

    def initialize(root_dir: DEFAULT_ROOT_DIR, request_path: DEFAULT_ROOT_REQUEST_PATH)
      self.root_dir = root_dir
      self.request_path = request_path
    end

    # Lazy stream of files that will be rendered by resources.
    def assets(glob = DEFAULT_GLOB)
      path_validator.glob(root_dir.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    # Returns a list of resources.
    def resources
      proxy.process unprocessed_resources
    end

    # Configure rules and manipulations that may happen to the proxy.
    def proxy
      @proxy ||= Proxy.new
    end

    # Find the page with a path.
    def find_by_request_path(request_path)
      resources.get(request_path)
    end

    def root_dir=(path)
      @root_dir = Pathname.new(path)
    end

    def request_path=(path)
      @request_path = Pathname.new(path)
    end

    private
    def path_validator
      @path_validator ||= PathValidator.new(safe_path: root_dir)
    end

    def unprocessed_resources
      Resources.new(root_file_path: root_dir).tap do |resources|
        assets.each { |a| resources.add_asset a }
      end
    end
  end
end
