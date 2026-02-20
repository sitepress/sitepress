require "mime/types"

module Sitepress
  # Base class for source files. A source represents a file on disk
  # without any web-serving concerns (handlers, formats, etc.).
  #
  # Example:
  #   source = Static.new(path: "fonts/roboto.woff2")
  #   source.mime_type  # => #<MIME::Type font/woff2>
  #   source.body       # => binary content
  #
  class Static
    attr_reader :path

    def initialize(path:)
      @path = Pathname.new(path)
    end

    def exists?
      path.exist?
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

    def fetch_data(key, *args, &block)
      data.fetch(key, *args, &block)
    rescue KeyError
      raise KeyError, "key not found: #{key.inspect} in #{path}"
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} path=#{path.to_s.inspect}>"
    end
  end
end
