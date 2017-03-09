module Sitepress
  # Manages collections of resources that share the same ResourceNode. Given the files `/a.html` and `/a.gif`,
  # both of these assets would be stored in the `ResourceNode#name = "a"` under `ResourceNode#formats` with
  # the extensions `.gif`, and `.html`.
  class Formats
    include Enumerable

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

    def add(asset: , ext: )
      resource = Resource.new(asset: asset, node: @node, ext: ext)
      if @formats.has_key? ext
        raise Sitepress::ExistingRequestPathError, "Resource at #{resource.request_path} already set"
      else
        @formats[ext] = resource
      end
    end

    def inspect
      "<#{self.class}: resources=#{map(&:request_path)}>"
    end
  end
end
