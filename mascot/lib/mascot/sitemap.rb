require "pathname"

module Mascot
  # A collection of pages from a directory.
  class Sitemap
    # Default file pattern to pick up in sitemap
    DEFAULT_GLOB = "**/**".freeze
    # Default root path for sitemap.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze
    # Default root request path
    DEFAULT_ROOT_REQUEST_PATH = Pathname.new("/").freeze

    attr_reader :root, :request_path, :extensions

    def initialize(root: DEFAULT_ROOT_PATH, request_path: DEFAULT_ROOT_REQUEST_PATH)
      self.root = root
      self.request_path = request_path
      @extensions = []
    end

    # Lazy stream of files that will be rendered by resources.
    def assets(glob = DEFAULT_GLOB)
      safe_root.glob(root.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    # Returns a list of resources.
    def resources
      Resources.new(root_file_path: root).tap do |resources|
        assets.each { |a| resources.add_asset a }
        process_resources resources
      end
    end

    # Find the page with a path.
    def get(request_path)
      resources.get(request_path)
    end

    def root=(path)
      @root = Pathname.new(path)
    end

    def request_path=(path)
      @request_path = Pathname.new(path)
    end

    private
    def process_resources(resources)
      @extensions.each { |exstension| exstension.process_resources(resources) }
    end

    def safe_root
      SafeRoot.new(path: root)
    end
  end
end
