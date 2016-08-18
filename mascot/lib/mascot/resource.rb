require "forwardable"
require "observer"

module Mascot
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    extend Forwardable
    def_delegators :asset, :mime_type

    attr_writer :body, :data
    attr_reader :node, :asset, :ext

    def initialize(asset: , node: , ext: "")
      @asset = asset
      @node = node
      @ext = ext # TODO: Meh, feels dirty but I suppose the thingy has to drop it in.
    end

    def request_path
      return unless node
      # TODO: This `compact` makes me nervous. How can we handle this better?

      lineage = node.parents.reverse.map(&:name).compact
      file_name = [node.name, @ext].join
      File.join("/", *lineage, file_name)
    end

    def inspect
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)} request_path=#{request_path.inspect} asset_path=#{@asset.path.to_s.inspect}>"
    end

    def data
      @data ||= asset.data
    end

    def parents
      return [] unless node
      node.parents.map(&:resource)
    end

    def siblings
      return [] unless node
      node.siblings.map(&:resources).flatten
    end

    def children
      return [] unless node
      node.children.map(&:resource)
    end

    def body
      @body ||= asset.body
    end
  end
end
