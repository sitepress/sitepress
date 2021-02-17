require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    class ResourceCompiler
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def compilation_path
        File.join(*resource.lineage, compilation_filename)
      end

      # Compiled assets have a slightly different filename for assets, especially the root node.
      def compilation_filename(path_builder: BuildPaths::DirectoryIndexPath, root_path_builder: BuildPaths::RootPath)
        path_builder = resource.node.root? ? root_path_builder : path_builder
        path_builder.new(resource).path
      end

      def render(page)
        Renderers::Server.new(resource).render
      end
    end

    attr_reader :site

    def initialize(site:, stdout: $stdout)
      @site = site
      @stdout = stdout
    end

    # Iterates through all pages and writes them to disk
    def compile(target_path:)
      target_path = Pathname.new(target_path)
      mkdir_p target_path
      cache_resources = @site.cache_resources
      @stdout.puts "Compiling #{@site.root_path.expand_path}"

      begin
        @site.cache_resources = true
        @site.resources.each do |resource|
          compiler = ResourceCompiler.new(resource)
          path = target_path.join(compiler.compilation_path)
          mkdir_p path.dirname
          if resource.renderable?
            @stdout.puts "  Rendering #{path}"
            File.open(path.expand_path, "w"){ |f| f.write compiler.render(resource) }
          else
            @stdout.puts "  Copying #{path}"
            FileUtils.cp resource.asset.path, path.expand_path
          end
        rescue => e
          @stdout.puts "Error compiling #{resource.inspect}"
          raise
        end
        @stdout.puts "Successful compilation to #{target_path.expand_path}"
      ensure
        @site.cache_resources = cache_resources
      end
    end
  end
end
