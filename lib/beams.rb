require "beams/version"

module Beams
  require "yaml"

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

  require "tilt"

  class TiltRenderer
    def initialize(resource)
      @resource = resource
    end

    def render
      template = engine.new { |t| @resource.body }
      template.render(Object.new, @resource.locals)
    end

    private
    def engine
      Tilt[@resource.file_path]
    end
  end

  # Mount inside of a config.ru file to run this as a server.
  class Server
    ROOT_PATH = Pathname.new("/")

    def initialize(sitemap, relative_to: "/")
      @relative_to = Pathname.new(relative_to)
      @sitemap = sitemap
    end

    def call(env)
      req = Rack::Request.new(env)
      if resource = @sitemap.find_by_request_path(normalize_path(req.path))
        [ 200, {"Content-Type" => resource.content_type}, [TiltRenderer.new(resource).render] ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end

    private
    # If we mount this middleware in a path other than root, we need to configure it
    # so that it correctly maps the request path to the content path.
    def normalize_path(request_path)
      ROOT_PATH.join(Pathname.new(request_path).relative_path_from(@relative_to)).to_s
    end
  end
end
