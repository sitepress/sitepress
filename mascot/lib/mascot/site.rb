require "pathname"
require "mascot/extensions/proc_manipulator"

module Mascot
  # A collection of pages from a directory.
  class Site
    # Default file pattern to pick up in site
    DEFAULT_GLOB = "**/**".freeze

    # Default root_path for site.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    attr_reader :root_path, :resources_pipeline

    # Cache resources for production runs of Mascot. Development
    # modes don't cache to optimize for files reloading.
    attr_accessor :cache_resources
    alias :cache_resources? :cache_resources

    # TODO: Get rid of these so that folks have ot call site.resources.get ...
    extend Forwardable
    def_delegators :resources, :get, :glob

    def initialize(root_path: DEFAULT_ROOT_PATH, cache_resources: false)
      self.root_path = root_path
      self.cache_resources = cache_resources
    end

    # A tree representation of the resourecs wthin the site.
    def root
      ResourcesNode.new.tap do |node|
        DirectoryCollection.new(assets: assets, path: root_path).mount(node)
        resources_pipeline.process node
      end
    end

    # Returns a list of all the resources within #root.
    def resources
      @resources = nil unless cache_resources
      @resources ||= ResourceCollection.new(node: root, root_path: root_path)
    end

    def root_path=(path)
      @root_path = Pathname.new(path)
    end

    # Quick and dirty way to manipulate resources in the site without
    # creating classes that implement the #process_resources method
    def manipulate(&block)
      resources_pipeline << Extensions::ProcManipulator.new(block)
    end

    def resources_pipeline
      @resources_pipeline ||= ResourcesPipeline.new
    end

    private
    # Lazy stream of files that will be rendered by resources.
    def assets(glob = DEFAULT_GLOB)
      Dir.glob(root_path.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end
  end
end
