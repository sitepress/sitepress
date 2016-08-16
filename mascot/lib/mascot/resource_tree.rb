module Mascot
  class ResourceTree
    attr_reader :parent, :resource, :name
    include Enumerable

    DELIMITER = "/".freeze

    def initialize(parent: nil, delimiter: ResourceTree::DELIMITER, name: nil)
      @parent = parent
      @name = name.freeze
      @children = Hash.new { |hash, key| hash[key] = ResourceTree.new(parent: self, delimiter: delimiter, name: key) }
      @delimiter = delimiter.freeze
    end

    def children
      @children.values
    end

    def each(&block)
      block.call(resource) if resource
      children.each{ |c| c.each(&block) }
    end

    def root?
      parent.nil?
    end

    def leaf?
      @children.empty?
    end

    def dig(*args)
      @children.dig(*args)
    end

    # TODO -- if there are children this should kill only the resource
    def remove
      parent.remove_child(name)
    end

    def siblings
      parent ? parent.children.select(&:resource).reject{ |c| c == self } : []
    end

    def parents
      parents = []
      node = parent
      while node do
        parents << node
        node = node.parent
      end
      parents
    end

    # We want this to be immutable so blow up if its ever set.
    def resource=(resource)
      if @resource
        raise Mascot::ExistingRequestPathError, "Resource at #{resource.request_path} already set"
      else
        @resource = resource
      end
    end

    def add(path, resource)
      segment, path = split(path)
      if path # We're still in path-land
        @children[segment].add(path, resource)
      else
        # Its a file, stamp out one more segment and set the resource
        segment = File.basename(segment, File.extname(segment))
        @children[segment].resource = resource
      end
    end

    def inspect
      "<Node:resource=#{resource.inspect} children=#{@children.inspect}>"
    end

    def get(path)
      @children.dig(*tokenize(path))
      # segment, path = split(path)
      # if path
      #   @children[segment].get(path)
      # else
      #   segment = File.basename(segment, File.extname(segment))
      #   @children[segment]
      # end
    end
    def remove_resource
      @resource = nil
    end

    def remove_child(path)
      *_, segment = tokenize(path)
      child = @children[segment]
      if child.leaf?
        @children.delete(segment)
      else
        child.remove_resource
      end
    end

    private
    def tokenize(path)
      path, _, file = path.gsub(/^\//, "").rpartition(@delimiter)
      file = File.basename(file, File.extname(file))
      path.split("/").push(file)
    end
    def split(path)
      # TODO: Should a path prefixed with "/" start from root?
      segment, _, path = path.gsub(/^\//, "").partition(@delimiter)
      path = nil if path == ""
      segment = nil if segment == ""
      [segment, path]
    end
  end
end
