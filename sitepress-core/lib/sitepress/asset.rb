require "mime/types"
require "forwardable"
require "fileutils"

module Sitepress
  # Represents a file on a web server that may be parsed to extract
  # metadata or be renderable via a template. Multiple resources
  # may point to the same asset. Properties of an asset should be mutable.
  # The Resource object is immutable and may be modified by the Resources proxy.
  class Asset
    # If we can't resolve a mime type for the resource, we'll fall
    # back to this binary octet-stream type so the client can download
    # the resource and figure out what to do with it.
    DEFAULT_MIME_TYPE = MIME::Types["application/octet-stream"].first

    # Parsers can be swapped out to deal with different types of resources, like Notion
    # documents, JSON, exif data on images, etc.
    DEFAULT_PARSER = Parsers::Frontmatter

    attr_reader :path

    extend Forwardable
    def_delegators :renderer, :render
    def_delegators :path, :handler, :node_name, :format, :exists?

    def initialize(path:, mime_type: nil, parser: DEFAULT_PARSER)
      # The MIME::Types gem returns an array when types are looked up.
      # This grabs the first one, which is likely the intent on these lookups.
      @mime_type = Array(mime_type).first
      @path = Path.new path
      @parser_klass = parser
    end

    def data
      @data ||= exists? ? parse_error { parser.data } : {}
    end

    def body
      @body ||= exists? ? parse_error { parser.body } : nil
    end

    # Treat resources with the same request path as equal.
    def ==(asset)
      path == asset.path
    end

    def mime_type
      @mime_type ||= inferred_mime_type || DEFAULT_MIME_TYPE
    end

    # Certain files, like binary file types, aren't something that we should try to
    # parse. When this returns true in some cases, a reference to the file will be
    # passed and skip all the overhead of trying to parse and render.
    def renderable?
      !!handler
    end

    # Set the parser equal to a thing.
    def parser=(parser_klass)
      @parser = nil
      @parser_klass = parser_klass
    end

    def updated_at
      File.mtime path
    end

    def created_at
      File.ctime path
    end

    def destroy
      FIleUtils.rm path
    end

    def save
      File.write path, render
    end

    def renderer
      @parser_klass::Renderer.new(data: data, body: body)
    end

    private
      def parse_error(&parse)
        parse.call
      rescue StandardError => e
        raise ParseError.new("Error parsing asset #{self.inspect}: #{e}")
      end

      def parser
        @parser ||= @parser_klass.new File.read path
      end

      # Returns the mime type of the file extension. If a type can't
      # be resolved then we'll just grab the first type.
      def inferred_mime_type
        format_extension = path.format&.to_s
        MIME::Types.type_for(format_extension).first if format_extension
      end
  end
end
