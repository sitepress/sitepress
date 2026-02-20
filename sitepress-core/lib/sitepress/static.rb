require "mime/types"
require "forwardable"

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
    extend Forwardable

    attr_reader :path

    def_delegators :path, :handler, :node_name, :format, :exists?

    def initialize(path:)
      @path = Path.new(path)
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
