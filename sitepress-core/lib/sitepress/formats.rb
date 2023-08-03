require "forwardable"

module Sitepress
  # Manages collections of resources that share the same Node. Given the files `/a.html` and `/a.gif`,
  # both of these assets would be stored in the `Node#name = "a"` under `Node#formats` with
  # the extensions `.gif`, and `.html`.
  class Formats
    include Enumerable

    extend Forwardable
    def_delegators :@registry, :size, :clear, :empty?
    def_delegators :@node, :default_format

    def initialize(node:)
      @node = node
      @registry = Hash.new
    end

    def each(&block)
      @registry.values.each(&block)
    end

    def remove(extension)
      @registry.delete symbolize(extension)
    end

    def get(extension)
      @registry[symbolize(extension || default_format)]
    end

    def extensions
      @registry.keys
    end

    def mime_type(mime_type)
      find { |f| f.mime_type == mime_type }
    end

    # TODO: Move this over to `node` so we don't have to inject that dependency
    # into this class.
    def add(asset:, format: nil)
      format = symbolize(format || default_format)

      resource = Resource.new(asset: asset, node: @node, format: format)
      if @registry.has_key? format
        raise Sitepress::ExistingRequestPathError, "Resource at #{resource.request_path} already set with format #{format.inspect}"
      else
        @registry[format] = resource
      end

      resource
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
