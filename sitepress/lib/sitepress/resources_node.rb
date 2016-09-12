module Sitepress
  # Resource nodes give resources their parent/sibling/child relationships. The relationship are determined
  # by the `request_path` given to an asset when its added to a node. Given the `request_path` `/foo/bar/biz/buz.html`,
  # a tree of resource nodes would be built named `foo`, `bar`, `biz`, `buz`. `foo` would be the "root" node and `buz`
  # a leaf node. The actual `buz.html` asset is then stored on the leaf node as a resource. This tree structure
  # makes it possible to reason through path relationships from code to build out elements in a website like tree navigation.
  class ResourcesNode
    attr_reader :parent, :name

    DELIMITER = "/".freeze

    def initialize(parent: nil, delimiter: ResourcesNode::DELIMITER, name: nil)
      @parent = parent
      @name = name.freeze
      @delimiter = delimiter.freeze
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

    def add(path: , asset: )
      head, *path = tokenize(path)
      if path.empty?
        # When there's no more paths, we're left with the format (e.g. ".html")
        formats.add(asset: asset, ext: head)
      else
        child_nodes[head].add(path: path, asset: asset)
      end
    end
    alias :[]= :add

    def get(path)
      *path, ext = tokenize(path)
      if node = dig(*path)
        node.formats.ext(ext)
      end
    end

    def get_node(path)
      *path, _ = tokenize(path)
      dig(*path)
    end
    alias :[] :get_node

    def inspect
      "<#{self.class}: formats=#{formats.map(&:request_path)} children=#{children.map(&:name).inspect}>"
    end

    # TODO: I don't really like how the path is broken up with the "ext" at the end.
    # It feels inconsistent. Either make an object/struct that encaspulates this or
    # just pass `index.html` through to the end.
    def dig(*args)
      head, *tail = args
      if head.nil? and tail.empty?
        self
      elsif child_nodes.has_key?(head)
        child_nodes[head].dig(*tail)
      else
        nil
      end
    end

    protected
    def remove_child(path)
      *_, segment, _ = tokenize(path)
      child_nodes.delete(segment)
    end

    private
    def add_child_node(name)
      ResourcesNode.new(parent: self, delimiter: @delimiter, name: name)
    end

    def child_nodes
      @child_nodes ||= Hash.new { |hash, key| hash[key] = add_child_node(key) }
    end

    # Returns all of the names for the path along with the format, if set.
    def tokenize(path)
      return path if path.respond_to? :to_a
      path, _, file = path.gsub(/^\//, "").rpartition(@delimiter)
      ext = File.extname(file)
      file = File.basename(file, ext)
      path.split(@delimiter).push(file).push(ext)
    end
  end
end
