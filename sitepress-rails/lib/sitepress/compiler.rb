require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    RenderingError = Class.new(RuntimeError)

    attr_reader :site, :build_path

    def initialize(site:, build_path:, stdout: $stdout)
      @site = site
      @stdout = stdout
      @build_path = Pathname.new(build_path)
    end

    # Iterates through all pages and writes them to disk
    def compile
      mkdir_p build_path
      cache_resources = @site.cache_resources
      @stdout.puts "Compiling #{@site.root_path.expand_path}"

      begin
        @site.cache_resources = true
        @site.resources.each do |resource|
          path = resource_build_path resource
          mkdir_p path.dirname

          if resource.renderable?
            @stdout.puts "  Rendering #{path}"
            File.open(path.expand_path, "w"){ |f| f.write resource_renderer(resource).render }
          else
            @stdout.puts "  Copying #{path}"
            FileUtils.cp resource.asset.path, path.expand_path
          end
        rescue => e
          @stdout.puts "Error compiling #{resource.inspect}"
          raise
        end
        @stdout.puts "Successful compilation to #{build_path.expand_path}"
      ensure
        @site.cache_resources = cache_resources
      end
    end

    private
      def resource_build_path(resource)
        path_builder = resource.node.root? ? BuildPaths::RootPath : BuildPaths::DirectoryIndexPath
        build_path.join path_builder.new(resource).path
      end

      def resource_renderer(resource)
        Renderers::Server.new(resource)
      end
  end
end
