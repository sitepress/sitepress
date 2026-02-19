require "mime/types"

module Sitepress
  # A source for static files that are served as-is without processing.
  # Used as a fallback for files that don't match Image or Page MIME types.
  #
  # Example:
  #   static = Static.new(path: "fonts/roboto.woff2")
  #   static.mime_type  # => #<MIME::Type font/woff2>
  #   static.body       # => binary content
  #
  class Static
    attr_reader :path

    def initialize(path:)
      @path = Pathname.new(path)
    end

    def node_name
      path.basename(".*").to_s.split(".").first
    end

    def format
      path.extname.delete(".").to_sym
    end

    def mime_type
      MIME::Types.type_for(path.to_s).first
    end

    def body
      File.binread(path)
    end

    def data
      @data ||= Data.manage({})
    end

    def exists?
      path.exist?
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} path=#{path.to_s.inspect} mime_type=#{mime_type}>"
    end
  end
end
