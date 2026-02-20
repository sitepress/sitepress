require "fileutils"
require "forwardable"

module Sitepress
  # A source for text-based files that may have frontmatter.
  # Handles parsing of YAML frontmatter and provides access to data and body.
  class Page < Static
    extend Forwardable

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

    def initialize(path:, parser: DEFAULT_PARSER)
      super(path: path)
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

    # Treat sources with the same path as equal.
    def ==(other)
      path == other.path
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

    private
      def parse_error(&parse)
        parse.call
      rescue StandardError => e
        raise ParseError, "Error parsing #{File.expand_path(path)}: #{e.class} - #{e.message}"
      end

      def parser
        @parser ||= @parser_klass.new File.read path
      end
  end

  # Backwards compatibility
  Asset = Page
end
