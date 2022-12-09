require "pathname"
require "sitepress/extensions/proc_manipulator"
require "forwardable"

module Sitepress
  # A collection of pages from a directory.
  class Site
    # Default file pattern to pick up in site
    DEFAULT_GLOB = "**/**".freeze

    # Default root_path for site.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    # Maps Rail-ish template files & structures into the site's node tree.
    DEFAULT_NODE_MAPPER = AssetNodeMapper

    attr_reader :root_path
    attr_accessor :node_mapper
    attr_writer :resources_pipeline

    # TODO: Get rid of these so that folks have ot call site.resources.get ...
    extend Forwardable
    def_delegators :resources, :get, :glob

    def initialize(root_path: DEFAULT_ROOT_PATH)
      self.root_path = root_path
      self.node_mapper = DEFAULT_NODE_MAPPER
    end

    # A tree representation of the resourecs wthin the site. The root is a node that's
    # processed by the `resources_pipeline`.
    def root
      @root ||= Node.new.tap do |node|
        node_mapper.new(path: pages_path, node: node).map
        resources_pipeline.process node
      end
    end

    # Returns a list of all the resources within #root.
    def resources
      @resources ||= ResourceCollection.new(node: root, root_path: pages_path)
    end

    def reload!
      @resources = @root = nil
      self
    end

    # Root path to website project. Contains helpers, pages, and more.
    def root_path=(path)
      @root_path = Pathname.new(path)
    end

    # Location of website pages.
    def pages_path
      @pages_path ||= root_path.join("pages")
    end

    def pages_path=(path)
      @pages_path = Pathname.new(path)
    end

    # Location of helper files.
    def helpers_path
      @helpers_path ||= root_path.join("helpers")
    end

    def helpers_path=(path)
      @helpers_path = Pathname.new(path)
    end

    # Location of rails assets
    def assets_path
      @assets_path ||= root_path.join("assets")
    end

    def assets_path=(path)
      @assets_path = Pathname.new(path)
    end

    # Location of pages models.
    def models_path
      @models_path ||= root_path.join("models")
    end

    def models_path=(path)
      @models_path = Pathname.new(path)
    end

    # Quick and dirty way to manipulate resources in the site without
    # creating classes that implement the #process_resources method.
    #
    # A common example may be adding data to a resource if it begins with a
    # certain path:
    #
    # ```ruby
    # Sitepress.site.manipulate do |root|
    #   root.get("videos").each do |resource|
    #     resource.data["layout"] = "video"
    #   end
    # end
    # ```
    #
    # A more complex, contrived example that sets index.html as the root node
    # in the site:
    #
    # ```ruby
    # Sitepress.site.manipulate do |root|
    #   root.get("blog").each do |post|
    #     post.move_to root
    #   end
    #
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
    # Node returned by #root.
    def resources_pipeline
      @resources_pipeline ||= ResourcesPipeline.new
    end
  end
end
