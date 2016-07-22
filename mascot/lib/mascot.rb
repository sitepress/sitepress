require "mascot/version"

require "forwardable"
require "pathname"
require "yaml"
require "mime/types"

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
    # If we can't resolve a mime type for the resource, we'll fall
    # back to this binary octet-stream type so the client can download
    # the resource and figure out what to do with it.
    DEFAULT_MIME_TYPE = MIME::Types["application/octet-stream"].first

    attr_reader :request_path, :file_path

    extend Forwardable
    def_delegators :@frontmatter, :data, :body

    def initialize(request_path: , file_path: , mime_type: nil)
      @request_path = request_path
      @file_path = Pathname.new file_path
      @frontmatter = Frontmatter.new File.read @file_path
      @mime_types = Array(mime_type) if mime_type
    end

    # List of all file extensions.
    def extensions
      @file_path.basename.to_s.split(".").drop(1)
    end

    # Returns the format extension.
    def format_extension
      extensions.first
    end

    # Returns a list of the rendering extensions.
    def template_extensions
      extensions.drop(1)
    end

    def mime_type
      (@mime_types ||= Array(resolve_mime_type)).push(DEFAULT_MIME_TYPE).first
    end

    private
    # Returns the mime type of the file extension. If a type can't
    # be resolved then we'll just grab the first type.
    def resolve_mime_type
      MIME::Types.type_for(format_extension) if format_extension
    end
  end

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

    # Lazy stream of resources.
    def resources(glob = DEFAULT_GLOB)
      Dir[@file_path.join(glob)].select(&File.method(:file?)).lazy.map do |path|
        Resource.new request_path: request_path(path), file_path: path
      end
    end

    # Find the page with a path.
    def find_by_request_path(request_path)
      resources.find { |r| r.request_path == File.join("/", request_path) }
    end

    def file_path=(path)
      @file_path = Pathname.new(path)
    end

    def request_path=(path)
      @request_path = Pathname.new(path)
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
