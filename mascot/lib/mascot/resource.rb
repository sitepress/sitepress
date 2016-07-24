require "mime/types"
require "yaml"
require "forwardable"
require "pathname"

module Mascot
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

    # Treat resources with the same request path as equal.
    def ==(resource)
      request_path == resource.request_path
    end

    private
    # Returns the mime type of the file extension. If a type can't
    # be resolved then we'll just grab the first type.
    def resolve_mime_type
      MIME::Types.type_for(format_extension) if format_extension
    end
  end
end
