require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    attr_reader :site, :build_path

    def initialize(site:, build_path:, stdout: $stdout)
      @site = site
      @stdout = stdout
      @build_path = Pathname.new(build_path)
    end

    # Iterates through all pages and writes them to disk
    def compile
      status "Compiling #{site.root_path.expand_path}"
      resources.each do |resource, path|
        if resource.renderable?
          status "  Rendering #{path}"
          File.open(path.expand_path, "w"){ |f| f.write render_resource(resource) }
        else
          status "  Copying #{path}"
          cp resource.asset.path, path.expand_path
        end
      rescue
        status "Error compiling #{resource.inspect}"
        raise
      end
      status "Successful compilation to #{build_path.expand_path}"
    end

    private
      def resource_build_path(resource)
        path_builder = resource.node.root? ? BuildPaths::RootPath : BuildPaths::DirectoryIndexPath
        build_path.join path_builder.new(resource).path
      end

      def render_resource(resource)
        Renderers::Server.new(resource).render
      end

      def status(message)
        @stdout.puts message
      end

      def resources
        Enumerator.new do |y|
          mkdir_p build_path
          cache_resources = site.cache_resources
          begin
            site.cache_resources = true
            site.resources.each do |resource|
              path = resource_build_path resource
              mkdir_p path.dirname
              y << [resource, path]
            end
          ensure
            site.cache_resources = cache_resources
          end
        end
      end
  end
end
