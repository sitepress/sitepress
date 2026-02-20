require "forwardable"

module Sitepress
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  #
  # The source can be any object that implements the Renderable protocol:
  # - #data - returns a Hash of metadata
  # - #render_in(view_context) - renders the content
  class Resource
    extend Forwardable
    def_delegators :source, :body

    attr_reader :node, :source
    alias :asset :source  # Backwards compatibility

    # Check if the source implements the data protocol.
    def has_data?
      source.respond_to?(:data)
    end

    # Check if the source implements the render_in protocol.
    def renderable?
      source.respond_to?(:render_in)
    end

    # Delegate to source.
    def data
      has_data? ? source.data : Data.manage({})
    end

    # Delegate to source.
    def fetch_data(key, *args, &block)
      source.fetch_data(key, *args, &block)
    end

    attr_accessor :format, :mime_type, :handler

    # Default scope for querying parent/child/sibling resources.
    DEFAULT_FILTER_SCOPE = :same

    def initialize(asset: nil, source: nil, node:, format: nil, mime_type: nil, handler: nil)
      @source = source || asset
      raise ArgumentError, "Either asset: or source: must be provided" unless @source
      @node = node
      @format = format || @source.format
      @mime_type = mime_type || @source.mime_type
      @handler = handler || source_handler
    end

    def request_path
      File.join("/", path)
    end

    # The `page_url|page_path` helper in Rails uses this method to determine the URL of a resource.
    def path
      File.join(*lineage, request_filename)
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
      self.class.new(source: @source, node: nil, format: @format, mime_type: @mime_type, handler: @handler)
    end

    # Removes the resource from the node's resources list.
    def remove
      node.resources.remove format if node
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} request_path=#{request_path.inspect} source=#{source.inspect}>"
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

    def render_in(view_context)
      renderable? ? source.render_in(view_context) : nil
    end

    private
    # Filters parent/child/sibling resources by a type. The default behavior is to only return
    # resources of the same type. For example given the pages `/a.html`, `/a.gif`, `/a/b.html`,
    # if you query the parent from page `/a/b.html` you'd only get `/a.html` by default. If you
    # query the parents via `parents(type: :all)` you'd get get [`/a.html`, `/a.gif`]
    def filter_resources(type: DEFAULT_FILTER_SCOPE, &block)
      return [] unless node
      nodes = block.call

      case type
      when :all
        nodes.map{ |node| node.resources }
      when :same
        nodes.map{ |n| n.resources.format(format) }.flatten
      when String, Symbol, NilClass
        nodes.map{ |n| n.resources.format(type) }.flatten
      when MIME::Type
        nodes.map{ |n| n.resources.mime_type(type) }.flatten
      else
        raise ArgumentError, "Invalid type argument #{type}. Must be either :same, :all, an extension string, or a Mime::Type"
      end
    end

    def source_handler
      @source.handler if @source.respond_to?(:handler)
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
