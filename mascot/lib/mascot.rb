require "mascot/version"

require "forwardable"
require "pathname"
require "yaml"

module Mascot
  # Parses metadata from the header of the page.
  class Frontmatter
    DELIMITER = "---".freeze
    PATTERN = /\A(#{DELIMITER}\n(.+)\n#{DELIMITER}\n)?(.+)\Z/m

    attr_reader :body

    def initialize(content)
      _, @data, @body = content.match(PATTERN).captures
    end

    def data
      @data ? YAML.load(@data) : {}
    end

    private
    def parse
      @content
    end
  end

  # Represents a page in a web server context.
  class Resource
    # TODO: I don't like the Binding, locals, and frontmatter
    # being in the Resource. That should be moved to a page
    # object and be delegated to that. Or perhaps the page body?
    # I'm moving forward with this now though to keep the objects simpler.
    # We'll see how it evolves.
    Binding = Struct.new(:data)

    CONTENT_TYPE = "text/html".freeze

    attr_reader :request_path, :file_path, :content_type

    extend Forwardable
    def_delegators :@frontmatter, :data, :body

    def initialize(request_path: , file_path: , content_type: CONTENT_TYPE)
      @request_path = request_path
      @content_type = content_type
      @file_path = Pathname.new file_path
      @frontmatter = Frontmatter.new File.read @file_path
    end

    # Locals that should be merged into or given to the rendering context.
    def locals
      { current_page: Binding.new(data) }
    end
  end

  # A collection of pages from a directory.
  class Sitemap
    # Default file pattern to pick up in sitemap
    DEFAULT_GLOB = "**/*.*".freeze
    # Default root path for sitemap.
    DEFAULT_ROOT_DIR = Pathname.new(".").freeze
    # Default root request path
    DEFAULT_ROOT_REQUEST_PATH = Pathname.new("/").freeze

    def initialize(file_path: DEFAULT_ROOT_DIR, request_path: DEFAULT_ROOT_REQUEST_PATH)
      @file_path = Pathname.new(file_path)
      @request_path = Pathname.new(request_path)
    end

    # Lazy stream of resources.
    def resources(glob = DEFAULT_GLOB)
      Dir[@file_path.join(glob)].lazy.map do |path|
        Resource.new request_path: request_path(path), file_path: path
      end
    end

    # Find the page with a path.
    def find_by_request_path(request_path)
      resources.find { |r| r.request_path == request_path }
    end

    private
    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def request_path(path)
      # Relative path of resource to the file_path of this project.
      relative_path = Pathname.new(path).relative_path_from(@file_path)
      # Removes the .fooz.baz
      @request_path.join(relative_path).to_s.sub(/\..*/, '')
    end
  end
end
