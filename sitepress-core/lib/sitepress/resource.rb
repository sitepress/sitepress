require "forwardable"

module Sitepress
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    extend Forwardable
    def_delegators :asset, :mime_type

    attr_writer :body, :data
    attr_reader :node, :asset, :format

    # Default scope for querying parent/child/sibling resources.
    DEFAULT_FILTER_SCOPE = :same

    def initialize(asset:, node:, format: nil)
      @asset = asset
      @node = node
      @format = format
    end

    def request_path
      return unless node

      if node.root?
        if node.default_format == format
          "/"
        elsif format
          File.join("/", "#{node.default_name}.#{format}")
        else
          File.join("/", node.default_name)
        end
      else
        # TODO: This `compact` makes me nervous. How can we handle this better?
        lineage = node.parents.reverse.map(&:name).compact
        file_name = if @format.nil? or @format.empty? or node.default_format == @format
          node.name
        else
          [node.name, ".", @format].join
        end
        File.join("/", *lineage, file_name.to_s)
      end
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

    def parent(**args)
      parents(**args).first
    end

    def parents(**args)
      filter_resources(**args){ node.parents }
    end

    def siblings(**args)
      filter_resources(**args){ node.siblings }.compact
    end

    def children(**args)
      filter_resources(**args){ node.children }.compact
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
        nodes.map{ |node| node.formats }
      when :same
        nodes.map{ |n| n.formats.get(format) }.flatten
      when String, Symbol, NilClass
        nodes.map{ |n| n.formats.get(type) }.flatten
      when MIME::Type
        nodes.map{ |n| n.formats.mime_type(type) }.flatten
      else
        raise ArgumentError, "Invalid type argument #{type}. Must be either :same, :all, an extension string, or a Mime::Type"
      end
    end
  end
end
