require "fileutils"

module Sitepress
  # Represents a page on a website - a file that may be parsed to extract
  # metadata or be renderable via a template. Multiple resources
  # may point to the same page. Properties of a page should be mutable.
  # The Resource object is immutable and may be modified by the Resources proxy.
  class Page < Static
    # If we can't resolve a mime type for the resource, we'll fall
    # back to this binary octet-stream type so the client can download
    # the resource and figure out what to do with it.
    DEFAULT_MIME_TYPE = MIME::Types["application/octet-stream"].first

    # MIME types that Page can handle - text-based content that may have frontmatter
    MIME_TYPES = %w[
      text/html
      text/plain
      text/markdown
      text/x-web-markdown
      text/css
      text/javascript
      application/json
      application/xml
      text/xml
      image/svg+xml
      text/x-haml
    ].freeze

    def self.mime_types
      MIME_TYPES
    end

    # Parsers can be swapped out to deal with different types of resources, like Notion
    # documents, JSON, exif data on images, etc.
    DEFAULT_PARSER = Parsers::Frontmatter

    attr_writer :body

    def_delegators :renderer, :render

    def initialize(path:, mime_type: nil, parser: DEFAULT_PARSER)
      super(path: path)
      # The MIME::Types gem returns an array when types are looked up.
      # This grabs the first one, which is likely the intent on these lookups.
      @mime_type = Array(mime_type).first
      @parser_klass = parser
    end

    def data
      @data ||= Data.manage(exists? ? parse_error { parser.data } : {})
    end

    def data=(data)
      @data = Data.manage(data)
    end

    def body
      @body ||= exists? ? parse_error { parser.body } : nil
    end

    # Returns the line number where the body starts in the original file.
    # Used to adjust error line numbers when frontmatter is present.
    def body_line_offset
      exists? ? parser.body_line_offset : 1
    end

    # Treat resources with the same request path as equal.
    def ==(other)
      path == other.path
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} path=#{path.to_s.inspect}>"
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

    # When changing the parser, clear all cached parsed data.
    def parser=(parser_klass)
      @parser = nil
      @data = nil
      @body = nil
      @parser_klass = parser_klass
    end

    def updated_at
      File.mtime path
    end

    def created_at
      File.ctime path
    end

    def destroy
      FileUtils.rm path
    end

    def save
      File.write path, render
    end

    def renderer
      @parser_klass::Renderer.new(data: data, body: body)
    end

    # Renders the page in a view context. This is part of the Renderable protocol
    # that allows any object to be used as a resource source.
    def render_in(view_context)
      template = ActionView::Template.new(
        body,
        path.to_s,
        ActionView::Template.handler_for_extension(handler),
        locals: []
      )
      template.render(view_context, {})
    end

    private
      def parse_error(&parse)
        parse.call
      rescue StandardError => e
        raise ParseError, "Error parsing #{path.expand_path}: #{e.class} - #{e.message}"
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

  # Backwards compatibility
  Asset = Page
end
