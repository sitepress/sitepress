require "pathname"
require "forwardable"

module Sitepress
  # A collection of pages from a directory.
  class Site
    # Default root_path for site.
    DEFAULT_ROOT_PATH = Pathname.new(".").freeze

    # TODO: Get rid of these so that folks have ot call site.resources.get ...
    extend Forwardable
    def_delegators :resources, :get, :glob

    def initialize(pages_path:)
      self.pages_path = pages_path
    end

    attr_reader :pages_path
    def pages_path=(path)
      @pages_path = Pathname.new(path)
    end

    # A tree representation of the resourecs wthin the site.
    def root
      @root ||= Node.new.tap { |root| manipulate_nodes root }
    end

    # Override this method to manipulate the construction of the Sitepress site. For example, let's
    # say you have a bunch of blog posts in date folders (please don't do this), like `./pages/posts/2022-12-19/my-post.html.erb`
    # that you want to access at `/posts/my-post`, you might do something like this:
    #
    # ```ruby
    # class MySite < Sitepress::Site
    #   def manipulate_nodes(root)
    #     super(root) # If you forget this, nothing will load from folders.
    #     blog = root.dig("posts")
    #     # This is actually a really bad idea, so don't do it. But if you must!
    #     blog.children.each do |date|
    #       dated_post = date.resources.flatten.resources.first { |r| r.format == :html }
    #       dated_post.move_to blog
    #     end
    #   end
    # end
    # ```
    #
    # Ok, why is this such a bad idea? Its a huge advantage to know that a file from `./posts/my-post`
    # can be found in `./app/content/pages/posts/my-post.html.erb`. When you add levels of indirection
    # between the files and the URLs, you make it more difficult to manage the content.
    def manipulate_nodes(root)
      asset_node_mapper(root).map
    end

    # Maps a path of directories and files into the root node.
    def asset_node_mapper(root_node)
      AssetNodeMapper.new(path: pages_path, node: root_node)
    end

    # Returns a list of all the resources within #root.
    def resources
      @resources ||= ResourceIndexer.new(node: root, root_path: pages_path)
    end

    def reload!
      @resources = @root = nil
      self
    end
  end
end
