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

    # Default scope for querying parent/child/sibling resources.
    DEFAULT_FILTER_SCOPE = :same

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

    def data
      @data ||= asset.data
    end

    def body
      @body ||= asset.body
    end

    def inspect
      "<#{self.class}:#{object_id} request_path=#{request_path.inspect} asset_path=#{@asset.path.to_s.inspect}>"
    end

    def parents(**args)
      filter_resources(**args){ node.parents }
    end

    def siblings(**args)
      filter_resources(**args){ node.siblings }
    end

    def children(**args)
      filter_resources(**args){ node.children }
    end

    def ==(resource)
      resource.request_path == request_path
    end

    private
    # Filters parent/child/sibling resources by a type. The default behavior is to only return
    # resources of the same type. For example given the pages `/a.html`, `/a.gif`, `/a/b.html`,
    # if you query the parent from page `/a/b.html` you'd only get `/a.html` by default. If you
    # query the parents via `parents(type: :all)` you'd get get [`/a.html`, `/a.gif`]
    #
    # TODO: When `type: :all` is scoped, some queries will mistakenly return single resources.
    # :all should return an array of arrays to accurately represention levels.
    #
    # TODO: Put a better extension/mime_type handler into resource tree, then instead of faltening
    # below and select, we could call a single map and pull out a resources
    def filter_resources(type: DEFAULT_FILTER_SCOPE, &block)
      return [] unless node
      nodes = block.call

      case type
      when :all
        nodes.map(&:formats)
      when :same
        nodes.map{ |n| n.formats.ext(ext) }.flatten.compact
      when String
        nodes.map{ |n| n.formats.ext(type) }.flatten.compact
      when MIME::Type
        nodes.map{ |n| n.formats.mime_type(type) }.flatten.compact
      else
        raise ArgumentError, "Invalid type argument #{type}. Must be either :same, :all, an extension string, or a Mime::Type"
      end
    end
  end
end
