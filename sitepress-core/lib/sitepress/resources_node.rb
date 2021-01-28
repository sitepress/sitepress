module Sitepress
  # Resource nodes give resources their parent/sibling/child relationships. The relationship are determined
  # by the `request_path` given to an asset when its added to a node. Given the `request_path` `/foo/bar/biz/buz.html`,
  # a tree of resource nodes would be built named `foo`, `bar`, `biz`, `buz`. `foo` would be the "root" node and `buz`
  # a leaf node. The actual `buz.html` asset is then stored on the leaf node as a resource. This tree structure
  # makes it possible to reason through path relationships from code to build out elements in a website like tree navigation.
  class ResourcesNode
    attr_reader :parent, :name

    DELIMITER = "/".freeze

    def initialize(parent: nil, name: nil)
      @parent = parent
      @name = name.freeze
      yield self if block_given?
    end

    def formats
      @formats ||= Formats.new(node: self)
    end

    # Returns the immediate children nodes.
    def children
      child_nodes.values
    end

    # Returns sibling nodes.
    def siblings
      parent ? parent.children.reject{ |c| c == self } : []
    end

    # Returns all parents up to the root node.
    def parents
      parents = []
      node = parent
      while node do
        parents << node
        node = node.parent
      end
      parents
    end

    def root?
      parent.nil?
    end

    def leaf?
      child_nodes.empty?
    end

    def flatten(resources: [])
      formats.each{ |resource| resources << resource }
      children.each do |child|
        child.flatten.each{ |resource| resources << resource }
      end
      resources
    end

    def remove
      if leaf?
        # TODO: Check the parents to see if they also need to be removed if
        # this call orphans the tree up to a resource.
        parent.remove_child(name)
      else
        formats.clear
      end
    end

    def get(path)
      path = Path.new(path)
      node = dig(*path.node_names)
      node.formats.ext(path.ext) if node
    end

    def get_node(path)
      path = Path.new(path)
      dig(*path.node_names)
    end
    alias :[] :get_node

    def build_child(name)
      child_nodes[name].tap do |node|
        yield node if block_given?
      end
    end

    def inspect
      "<#{self.class}: name=#{name.inspect} formats=#{formats.map(&:request_path)} children=#{children.map(&:name).inspect}>"
    end

    # TODO: I don't really like how the path is broken up with the "ext" at the end.
    # It feels inconsistent. Either make an object/struct that encaspulates this or
    # just pass `index.html` through to the end.
    def dig(*args)
      head, *tail = args
      if (head.nil? or head.empty?) and tail.empty?
        self
      elsif child_nodes.has_key?(head)
        child_nodes[head].dig(*tail)
      else
        nil
      end
    end

    protected
    def remove_child(path)
      child_nodes.delete(Path.new(path).node_names.last)
    end

    private
    def add_child_node(name)
      ResourcesNode.new(parent: self, name: name)
    end

    def child_nodes
      @child_nodes ||= Hash.new { |hash, key| hash[key] = add_child_node(key) }
    end
  end
end
