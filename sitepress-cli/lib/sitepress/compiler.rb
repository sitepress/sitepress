require "pathname"
require "fileutils"
require "sitepress-server"

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
      cache_resources = @site.cache_resources
      @stdout.puts "Compiling #{@site.root_path.expand_path}"

      begin
        @site.cache_resources = true
        @site.resources.each do |resource|
          path = target_path.join(resource.compilation_path)
          mkdir_p path.dirname
          @stdout.puts "  #{path}"
          File.open(path.expand_path, "w"){ |f| f.write render(resource) }
        end
        @stdout.puts "Successful compilation to #{target_path.expand_path}"
      ensure
        @site.cache_resources = cache_resources
      end
    end

    private
    def render(page)
      Renderers::Server.new(page).compile
    end
  end
end
