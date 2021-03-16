require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    attr_reader :site, :root_path

    def initialize(site:, root_path:, stdout: $stdout)
      @site = site
      @stdout = stdout
      @root_path = Pathname.new(root_path)
    end

    # Iterates through all pages and writes them to disk
    def compile
      status "Building #{site.root_path.expand_path} to #{root_path.expand_path}"
      resources.each do |resource, path|
        if resource.renderable?
          status "  Rendering #{path}"
          File.open(path.expand_path, "w"){ |f| f.write render resource }
        else
          status "  Copying #{path}"
          cp resource.asset.path, path.expand_path
        end
      rescue
        status "Error building #{resource.inspect}"
        raise
      end
      status "Successful build to #{root_path.expand_path}"
    end

    private
      def resources
        Enumerator.new do |y|
          mkdir_p root_path
          cache_resources = site.cache_resources
          begin
            site.cache_resources = true
            site.resources.each do |resource|
              path = build_path resource
              mkdir_p path.dirname
              y << [resource, path]
            end
          ensure
            site.cache_resources = cache_resources
          end
        end
      end

      def build_path(resource)
        path_builder = resource.node.root? ? BuildPaths::RootPath : BuildPaths::DirectoryIndexPath
        root_path.join path_builder.new(resource).path
      end

      def render(resource)
        Renderers::Server.new(resource).render
      end

      def status(message)
        @stdout.puts message
      end
  end
end
