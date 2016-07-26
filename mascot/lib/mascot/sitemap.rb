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
      path_validator.glob(file_path.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    # TODO: We need to do more stuff with the resources after we have them. e.g. add resources, remove resources,
    # and rename resources. How can we hook into that? We need a hook, that's the trick rick. add/remove should be hooks.
    def resources
      Resources.new(root_file_path: file_path).tap do |resources|
        assets.each { |a| resources.add_asset a }
      end
    end

    # Find the page with a path.
    def find_by_request_path(request_path)
      resources.get(request_path)
    end

    def file_path=(path)
      @file_path = Pathname.new(path)
    end

    def request_path=(path)
      @request_path = Pathname.new(path)
    end

    private
    def path_validator
      @path_validator ||= PathValidator.new(safe_path: file_path)
    end
  end
end
