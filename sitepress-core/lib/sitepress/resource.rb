require "forwardable"

module Sitepress
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    extend Forwardable
    def_delegators :asset, :renderable?

    attr_writer :body, :data
    attr_reader :node, :asset

    attr_accessor :format, :mime_type, :handler

    # Default scope for querying parent/child/sibling resources.
    DEFAULT_FILTER_SCOPE = :same

    def initialize(asset:, node:, format: nil, mime_type: nil, handler: nil)
      @asset = asset
      @node = node
      @format = format || asset.format
      @mime_type = mime_type || asset.mime_type
      @handler = handler || asset.handler
    end

    def request_path
      File.join("/", *lineage, request_filename)
    end

    def data
      @data ||= asset.data
    end

    def body
      @body ||= asset.body
    end

    def copy_to(destination)
      destination.add_child(node.name).formats.add asset: asset, format: format
    end

    def move_to(destination)
      copy_to destination
      delete
    end

    def delete
      node.formats.remove format
    end

    def inspect
      "<#{self.class}:#{object_id} request_path=#{request_path.inspect} asset_path=#{asset.path.to_s.inspect}>"
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

    # Used internally to construct paths from the current node up to the root node.
    def lineage
      @lineage ||= node.parents.reject(&:root?).reverse.map(&:name)
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

    # Deals with situations, particularly in the root node and other "index" nodes, for the `request_path`
    def request_filename
      if node.root? and node.default_format == format
        ""
      elsif node.root? and format
        "#{node.default_name}.#{format}"
      elsif node.root?
        node.default_name
      elsif format.nil? or node.default_format == format
        node.name
      else
        "#{node.name}.#{format}"
      end
    end
  end
end
