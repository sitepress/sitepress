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

    def initialize(root_path: DEFAULT_ROOT_PATH)
      self.root_path = root_path
    end

    def glob(glob)
      root.resources.glob(root_path.join(glob))
    end

    # Returns a list of resources.
    def root
      ResourcesNode.new.tap do |root_node|
        DirectoryCollection.new(assets: assets, path: root_path).mount(root_node)
        resources_pipeline.process root_node
      end
    end

    # Quick and dirty way to manipulate resources in the site without
    # creating classes that implement the #process_resources method
    def manipulate(&block)
      resources_pipeline << Extensions::ProcManipulator.new(block)
    end

    # Find the page with a path.
    def get(request_path)
      root.get_resource(request_path)
    end

    def root_path=(path)
      @root_path = Pathname.new(path)
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