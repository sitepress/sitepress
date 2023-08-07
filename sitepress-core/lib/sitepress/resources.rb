require "forwardable"

module Sitepress
  # Manages collections of resources that share the same Node. Given the files `/a.html` and `/a.gif`,
  # both of these assets would be stored in the `Node#name = "a"` under `Node#formats` with
  # the formats `.gif`, and `.html`.
  class Resources
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

    def formats
      @registry.keys
    end

    def mime_type(mime_type)
      find { |f| f.mime_type == mime_type }
    end

    def add(resource)
      if @registry.has_key? resource.format
        raise Sitepress::ExistingRequestPathError, "Resource at #{resource.request_path} already set with format #{resource.format.inspect}"
      else
        @registry[resource.format] = resource
      end
    end

    def flatten(resources: [])
      each { |resource| resources << resource }
      @node.children.each do |child|
        child.resources.flatten.each { |resource| resources << resource }
      end
      resources
    end

    def add_asset(asset, format: nil)
      format = symbolize(format || default_format)
      add Resource.new(asset: asset, node: @node, format: format)
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
