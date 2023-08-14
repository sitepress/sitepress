require "forwardable"

module Sitepress
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    extend Forwardable
    def_delegators :asset, :body, :data, :renderable?

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

    # Eugh, I really don't like this because it's not a full URL. To get a full URL though this thing
    # needs to be put into `url_for(request_path)` in Rails to get the hostname. I don't want to inject
    # that dependency into this thing, so here it is.
    alias :url :request_path

    def node=(destination)
      if destination.resources.format? format
        raise Sitepress::Error, "#{destination.inspect} already has a resource with a #{format} format"
      end
      remove
      destination.resources.add self
      @node = destination
    end

    # Moves the resource to a destination node. Moving a resource to a Sitepress::Node
    # is a little weird for people who are accustomed to working with files, which is pretty
    # much everybody (including myself). A child node has to be created on the destination node
    # with the name of the resource node.
    #
    # Or just ignore all of that and use the `move_to` method so you can feel like you're
    # moving files around.
    def move_to(destination)
      raise Sitepress::Error, "#{destination.inspect} is not a Sitepress::Node" unless destination.is_a? Sitepress::Node
      self.tap do |resource|
        resource.node = destination.child(node.name)
      end
    end

    # Creates a duplicate of the resource and moves it to the destination.
    def copy_to(destination)
      raise Sitepress::Error, "#{destination.inspect} is not a Sitepress::Node" unless destination.is_a? Sitepress::Node
      self.clone.tap do |resource|
        resource.node = destination.child(node.name)
      end
    end

    # Clones should be initialized with a nil node. Initializing with a node would mean that multiple resources
    # are pointing to the same node, which shouldn't be possible.
    def clone
      self.class.new(asset: @asset, node: nil, format: @format, mime_type: @mime_type, handler: @handler)
    end

    # Removes the resource from the node's resources list.
    def remove
      node.resources.remove format if node
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
      node.parents.reject(&:root?).reverse.map(&:name)
    end

    class << self
      attr_accessor :path_suffix_hack_that_you_should_not_use

      def path_suffix_hack_that_you_should_not_use
        @path_suffix_hack_that_you_should_not_use ||= ""
      end
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
        nodes.map{ |node| node.resources }
      when :same
        nodes.map{ |n| n.resources.get(format) }.flatten
      when String, Symbol, NilClass
        nodes.map{ |n| n.resources.get(type) }.flatten
      when MIME::Type
        nodes.map{ |n| n.resources.mime_type(type) }.flatten
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
        "#{node.default_name}#{self.class.path_suffix_hack_that_you_should_not_use}"
      elsif format.nil? or node.default_format == format
        "#{node.name}#{self.class.path_suffix_hack_that_you_should_not_use}"
      else
        "#{node.name}.#{format}"
      end
    end
  end
end
