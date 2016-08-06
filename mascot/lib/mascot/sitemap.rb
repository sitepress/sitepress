require "pathname"
require "mascot/extensions/proc_manipulator"

module Mascot
  # A collection of pages from a directory.
  class Sitemap
    # Default file pattern to pick up in sitemap
    DEFAULT_GLOB = "**/**".freeze
    # Default root path for sitemap.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    attr_reader :root, :resources_pipeline

    def initialize(root: DEFAULT_ROOT_PATH)
      self.root = root
    end

    # Lazy stream of files that will be rendered by resources.
    def assets(glob = DEFAULT_GLOB)
      safe_root.glob(root.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end

    # Returns a list of resources.
    def resources
      Resources.new(root_file_path: root).tap do |resources|
        assets.each { |a| resources.add_asset a }
        resources_pipeline.process resources
      end
    end

    # Quick and dirty way to manipulate resources in the sitemap without
    # creating classes that implement the #process_resources method
    def manipulate(&block)
      resources_pipeline << Extensions::ProcManipulator.new(block)
    end

    # Find the page with a path.
    def get(request_path)
      resources.get(request_path)
    end

    def root=(path)
      @root = Pathname.new(path)
    end

    def resources_pipeline
      @resources_pipeline ||= ResourcesPipeline.new
    end

    private
    def safe_root
      SafeRoot.new(path: root)
    end
  end
end
