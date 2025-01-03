module Sitepress
  # Resource nodes give resources their parent/sibling/child relationships. The relationship are determined
  # by the `request_path` given to an asset when its added to a node. Given the `request_path` `/foo/bar/biz/buz.html`,
  # a tree of resource nodes would be built named `foo`, `bar`, `biz`, `buz`. `foo` would be the "root" node and `buz`
  # a leaf node. The actual `buz.html` asset is then stored on the leaf node as a resource. This tree structure
  # makes it possible to reason through path relationships from code to build out elements in a website like tree navigation.
  class Node
    extend Forwardable
    def_delegators :resources, :formats, :format, :format?

    attr_reader :parent, :name, :default_format, :default_name, :resources

    DEFAULT_FORMAT = :html

    DEFAULT_NAME = "index".freeze

    def initialize(parent: nil, name: nil, default_format: DEFAULT_FORMAT, default_name: DEFAULT_NAME)
      @name = name.freeze
      @parent = parent
      @children = Hash.new
      @resources = Resources.new(node: self)
      @default_format = default_format
      @default_name = default_name
      yield self if block_given?
    end

    # Returns the immediate children nodes.
    def children
      @children.values
    end

    # Returns sibling nodes and self.
    def siblings
      parent ? parent.children : []
    end

    # Returns all parents up to the root node.
    def parents
      Enumerator.produce(parent, &:parent).take_while(&:itself)
    end

    def root?
      parent.nil?
    end

    def leaf?
      @children.empty?
    end

    def parent=(parent)
      child = self

      if parent == @parent
        return
      elsif parent.nil?
        remove
        return
      # Make sure we don't change the parent of this node to one if its children; otherwise
      # we'd have to jump into a time machine and do some really weird stuff with Doc Whatever-his-name-is.
      elsif child.children.include? parent
        raise Sitepress::Error, "Parent node can't be changed to one of its children"
      # Check if the name of this node exists as a child on the new parent.
      elsif parent.child? child.name
        raise Sitepress::Error, "Node exists with the name #{child.name.inspect} in #{parent.inspect}. Remove existing node."
      else
        @parent = parent
        parent.overwrite_child child
      end
    end

    def remove
      return if @parent.nil?
      @parent.remove_child name
      @parent = nil
    end

    def get(path)
      path = Path.new(path)
      node = dig(*path.node_names)
      node.resources.format(path.format) if node
    end

    def child(name)
      return self if name == default_name

      @children.fetch(name){ @children[name] = build_child(name: name) }.tap do |child|
        yield child if block_given?
      end
    end

    def child?(name)
      @children.key? name
    end

    def inspect
      "<#{self.class}: name=#{name.inspect}, formats=#{formats.inspect}, children=#{children.map(&:name).inspect}, resource_request_paths=#{resources.map(&:request_path)}>"
    end

    def dig(*args)
      head, *tail = args
      if (head.nil? or head.empty? or head == default_name) and tail.empty?
        self
      elsif child?(head)
        @children[head].dig(*tail)
      else
        nil
      end
    end

    protected
    def remove_child(name)
      @children.delete(name)
    end

    def overwrite_child(node)
      @children[node.name] = node
    end

    private
    def build_child(**kwargs)
      Node.new(parent: self, default_format: default_format, default_name: default_name, **kwargs)
    end
  end
end
