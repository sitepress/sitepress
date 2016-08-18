module Mascot
  # Resource nodes give resources their parent/sibling/child relationships. The relationship are determined
  # by the `request_path` given to an asset when its added to a node. Given the `request_path` `/foo/bar/biz/buz.html`,
  # a tree of resource nodes would be built named `foo`, `bar`, `biz`, `buz`. `foo` would be the "root" node and `buz`
  # a leaf node. The actual `buz.html` asset is then stored on the leaf node as a resource. This tree structure
  # makes it possible to reason through path relationships from code to build out elements in a website like tree navigation.
  class ResourcesNode
    # TODO: Should it be called "formats" or "extensions"? Probably the latter, but that could conflict with Resource Manipulators.
    attr_reader :parent, :name, :formats
    include Enumerable

    DELIMITER = "/".freeze

    def initialize(parent: nil, delimiter: ResourcesNode::DELIMITER, name: nil)
      @parent = parent
      @name = name.freeze
      @delimiter = delimiter.freeze
      @children = Hash.new { |hash, key| hash[key] = ResourcesNode.new(parent: self, delimiter: delimiter, name: key) }
      @resources = Hash.new
    end

    # Returns the immediate children nodes.
    def children
      @children.values
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

    # Iterates through resources in the current node and all child resources.
    # TODO: Should this include all children? Perhaps I should move this method
    # into an eumerator that more clearly states it returns an entire sub-tree.
    def each(&block)
      @resources.values.each { |resource| block.call(resource) }
      children.each{ |c| c.each(&block) }
    end

    def root?
      parent.nil?
    end

    def leaf?
      @children.empty?
    end

    def resources
      @resources.values
    end

    def remove_resource(resource)
      @resources.delete resource.ext #if @resources[resource.ext] == resource
    end

    def remove
      if leaf?
        # TODO: Check the parents to see if they also need to be removed if
        # this call orphans the tree up to a resource.
        parent.remove_child(name)
      else
        @resources.clear
      end
    end

    def add(path: , asset: )
      head, *path = tokenize(path)
      if path.empty?
        # When there's no more paths, we're left with the format (e.g. ".html")
        add_format(asset: asset, ext: head)
      else
        @children[head].add(path: path, asset: asset)
      end
    end
    alias :[]= :add

    def get_resource(path)
      *path, ext = tokenize(path)
      if node = dig(*path)
        node.get_format(ext: ext)
      end
    end

    def inspect
      "<#{self.class}: resources=#{resources.map(&:request_path)} children=#{children.map(&:name).inspect}>"
    end

    def get(path)
      *path, ext = tokenize(path)
      dig(*path)
    end
    alias :[] :get

    protected
    def get_format(ext: "")
      @resources[ext]
    end

    def remove_child(path)
      *_, segment, _ = tokenize(path)
      @children.delete(segment)
    end

    def add_format(asset: , ext: )
      resource = Resource.new(asset: asset, node: self, ext: ext)
      if @resources.has_key? ext
        raise Mascot::ExistingRequestPathError, "Resource at #{resource.request_path} already set"
      else
        @resources[ext] = resource
      end
    end

    # TODO: I don't really like how the path is broken up with the "ext" at the end.
    # It feels inconsistent. Either make an object/struct that encaspulates this or
    # just pass `index.html` through to the end.
    def dig(*args)
      head, *tail = args
      if head.nil? and tail.empty?
        self
      elsif @children.has_key?(head)
        @children[head].dig(*tail)
      else
        nil
      end
    end

    private
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
