module Mascot
  # Represents a collection of resources. Provides interfaces to query
  # resource via globbing, paths, etc.
  class ResourceCollection
    extend Forwardable
    def_delegators :resources, :each, :size

    include Enumerable

    # Used by `#glob` to determine the full path when
    # given a relative glob pattern.
    attr_reader :root_path

    def initialize(node: , root_path: ".")
      @node = node
      @root_path = Pathname.new(root_path)
    end

    def glob(pattern)
      paths = Dir.glob root_path.join(pattern)
      resources.select { |r| paths.include? r.asset.path.to_s }
    end

    def get(request_path)
      @node.get(request_path)
    end

    private
    def resources
      @node.flatten
    end
  end
end
