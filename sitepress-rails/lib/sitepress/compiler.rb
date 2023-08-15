require "pathname"
require "fileutils"

module Sitepress
  module Compiler
    class Abstract
      include Enumerable

      attr_reader :site, :failed, :succeeded

      # If a resource can't render, it will raise an exception and stop the compiler. Sometimes
      # its useful to turn off errors so you can get through a full compilation and see how many
      # errors you encounter along the way. To do that, you'd set `fail_on_error` to
      # `false` and the compile will get through all the resources.
      attr_accessor :fail_on_error

      def initialize(site:, stdout: $stdout, fail_on_error: false)
        @site = site
        @stdout = stdout
        @fail_on_error = fail_on_error
        @failed = []
        @succeeded = []
      end

      # Iterates through all pages and writes them to disk
      def compile
        before_compile
        each do |resource, *args, **kwargs|
          if resource.renderable?
            render_resource(resource, *args, **kwargs)
          else
            copy_resource(resource, *args, **kwargs)
          end
          @succeeded << resource
        rescue
          status "Error building #{resource.inspect}"
          @failed << resource
          raise if fail_on_error
        end
        after_compile
      end

      def each(&block)
        site.resources.each(&block)
      end

      protected
        def copy_resource(resource, *args, **kwargs)
          raise NotImplementedError
        end

        def render_resource(resource, *args, **kwargs)
          raise NotImplementedError
        end

        def before_compile
          status "Building #{site.pages_path.expand_path}"
        end

        def after_compile
          status "Built #{site.pages_path.expand_path}"
        end

        def render(resource)
          Renderers::Server.new(resource).render
        end

        def status(message)
          @stdout.puts message
        end
    end

    # Compile all resources from a Sitepress site into static pages.
    class Files < Abstract
      include FileUtils

      attr_reader :root_path

      def initialize(*args, root_path:, **kwargs, &block)
        super(*args, **kwargs, &block)
        @root_path = Pathname.new(root_path)
      end

      protected
        def render_resource(resource, path)
          status "Rendering #{path}"
          File.open(path.expand_path, "w"){ |f| f.write render resource }
        end

        def copy_resource(resource, path)
          status "Copying #{path}"
          cp resource.asset.path, path.expand_path
        end

        def before_compile
          mkdir_p root_path
          status "Building #{site.pages_path.expand_path} to #{root_path.expand_path}"
        end

        def after_compile
          status "Build at #{root_path.expand_path}"
        end

        def each
          site.resources.each do |resource|
            path = build_path resource
            mkdir_p path.dirname
            yield resource, path
          end
        end

        def build_path(resource)
          path_builder = resource.node.root? ? BuildPaths::RootPath : BuildPaths::DirectoryIndexPath
          root_path.join path_builder.new(resource).path
        end
    end
  end
end
