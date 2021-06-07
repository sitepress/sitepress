require "forwardable"

module Sitepress
  # Manages collections of resources that share the same Node. Given the files `/a.html` and `/a.gif`,
  # both of these assets would be stored in the `Node#name = "a"` under `Node#formats` with
  # the extensions `.gif`, and `.html`.
  class Formats
    include Enumerable

    extend Forwardable
    def_delegators :@formats, :size, :clear
    def_delegators :@node, :default_format

    def initialize(node: )
      @node = node
      @formats = Hash.new
    end

    def each(&block)
      @formats.values.each(&block)
    end

    def remove(extension)
      @formats.delete symbolize(extension)
    end

    def get(extension)
      @formats[symbolize(extension || default_format)]
    end

    def extensions
      @formats.keys
    end

    def mime_type(mime_type)
      find { |f| f.mime_type == mime_type }
    end

    def add(asset:, format: nil)
      format = symbolize(format || default_format)

      resource = Resource.new(asset: asset, node: @node, format: format)
      if @formats.has_key? format
        raise Sitepress::ExistingRequestPathError, "Resource at #{resource.request_path} already set with format #{format.inspect}"
      else
        @formats[format] = resource
      end
    end

    def inspect
      "<#{self.class}: resources=#{map(&:request_path)}>"
    end

    private
    def symbolize(format)
      format&.to_sym
    end
  end
end
