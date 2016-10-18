require "pathname"
require "sitepress/extensions/proc_manipulator"

module Sitepress
  # A collection of pages from a directory.
  class Site
    # Default file pattern to pick up in site
    DEFAULT_GLOB = "**/**".freeze

    # Default root_path for site.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    attr_reader :root_path, :resources_pipeline

    # Cache resources for production runs of Sitepress. Development
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

    # A tree representation of the resourecs wthin the site. The root is a node that's
    # processed by the `resources_pipeline`.
    def root
      ResourcesNode.new.tap do |node|
        DirectoryCollection.new(assets: pages_assets, path: pages_path).mount(node)
        resources_pipeline.process node
      end
    end

    # Returns a list of all the resources within #root.
    def resources
      @resources = nil unless cache_resources
      @resources ||= ResourceCollection.new(node: root, root_path: root_path)
    end

    # Root path to website project. Contains helpers, pages, and more.
    def root_path=(path)
      @root_path = Pathname.new(path)
    end

    # Location of website pages.
    def pages_path
      root_path.join("pages")
    end

    # Quick and dirty way to manipulate resources in the site without
    # creating classes that implement the #process_resources method.
    #
    # A common example may be adding data to a resource if it begins with a
    # certain path:
    #
    # ```ruby
    # Sitepress.site.manipulate do |resource, root|
    #   if resource.request_path.start_with? "/videos/"
    #     resource.data["layout"] = "video"
    #   end
    # end
    # ```
    #
    # A more complex, contrived example that sets index.html as the root node
    # in the site:
    #
    # ```ruby
    # Sitepress.site.manipulate do |resource, root|
    #   if resource.request_path == "/index"
    #     # Remove the HTML format of index from the current resource level
    #     # so we can level it up.
    #     node = resource.node
    #     node.formats.remove ".html"
    #     node.remove
    #     root.add path: "/", asset: resource.asset # Now we can get to this from `/`.
    #   end
    # end
    # ```
    def manipulate(&block)
      resources_pipeline << Extensions::ProcManipulator.new(block)
    end

    # An array of procs that manipulate the tree and resources from the
    # ResourceNode returned by #root.
    def resources_pipeline
      @resources_pipeline ||= ResourcesPipeline.new
    end

    private
    # Lazy stream of files that will be rendered by resources.
    def pages_assets(glob = DEFAULT_GLOB)
      Dir.glob(pages_path.join(glob)).select(&File.method(:file?)).lazy.map do |path|
        Asset.new(path: path)
      end
    end
  end
end
