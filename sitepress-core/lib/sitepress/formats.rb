module Sitepress
  # Manages collections of resources that share the same Node. Given the files `/a.html` and `/a.gif`,
  # both of these assets would be stored in the `Node#name = "a"` under `Node#formats` with
  # the extensions `.gif`, and `.html`.
  class Formats
    include Enumerable

    # This is our "default" extension, which is usually an html file. Other formats,
    # like .png or .css, would require an explicit extension.
    BLANK_EXTENSION = "".freeze

    extend Forwardable
    def_delegators :@formats, :size, :clear

    def initialize(node: )
      @node = node
      @formats = Hash.new
    end

    def each(&block)
      @formats.values.each(&block)
    end

    def remove(ext)
      @formats.delete(ext)
    end

    def ext(ext)
      @formats[ext]
    end

    def extensions
      @formats.keys
    end

    def mime_type(mime_type)
      find { |f| f.mime_type == mime_type }
    end

    def add(asset:, format: nil)
      ext = format ? ".#{format}" : ""
      resource = Resource.new(asset: asset, node: @node, ext: ext)
      if @formats.has_key? ext
        raise Sitepress::ExistingRequestPathError, "Resource at #{resource.request_path} already set with format #{ext.inspect}"
      else
        @formats[ext] = resource
      end
    end

    def inspect
      "<#{self.class}: resources=#{map(&:request_path)}>"
    end
  end
end
