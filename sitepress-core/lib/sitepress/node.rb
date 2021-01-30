module Sitepress
  # Resource nodes give resources their parent/sibling/child relationships. The relationship are determined
  # by the `request_path` given to an asset when its added to a node. Given the `request_path` `/foo/bar/biz/buz.html`,
  # a tree of resource nodes would be built named `foo`, `bar`, `biz`, `buz`. `foo` would be the "root" node and `buz`
  # a leaf node. The actual `buz.html` asset is then stored on the leaf node as a resource. This tree structure
  # makes it possible to reason through path relationships from code to build out elements in a website like tree navigation.
  class Node
    attr_reader :parent, :name

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
      formats.clear
      parent.remove_child(name) if leaf?
    end

    def get(path)
      path = Path.new(path)
      node = dig(*path.node_names)
      node.formats.get(path.format) if node
    end

    def add_child(name)
      child_nodes[name].tap do |node|
        yield node if block_given?
      end
    end

    def inspect
      "<#{self.class}: name=#{name.inspect} formats=#{formats.map(&:request_path)} children=#{children.map(&:name).inspect}>"
    end

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
    def remove_child(name)
      child_nodes.delete(name)
    end

    private
    def build_child(name)
      Node.new(parent: self, name: name)
    end

    def child_nodes
      @child_nodes ||= Hash.new { |hash, key| hash[key] = build_child(key) }
    end
  end
end
