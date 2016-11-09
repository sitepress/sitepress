require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    def initialize(site:, stdout: $stdout)
      @site = site
      @stdout = stdout
    end

    # Iterates through all pages and writes them to disk
    def compile(target_path:)
      target_path = Pathname.new(target_path)
      mkdir_p target_path
      root = Pathname.new("/")
      @stdout.puts "Compiling #{@site.root_path.expand_path}"
      @site.resources.each do |resource|
        # These are root `resource.request_path`
        derooted = Pathname.new(resource.request_path).relative_path_from(root)
        path = target_path.join(derooted)
        mkdir_p path.dirname
        @stdout.puts "  #{path}"
        File.open(path.expand_path, "w"){ |f| f.write render(resource) }
      end
      @stdout.puts "Successful compilation to #{target_path.expand_path}"
    end

    private
    def render(resource)
      RenderingContext.new(resource: resource, site: @site).render
    end
  end
end
