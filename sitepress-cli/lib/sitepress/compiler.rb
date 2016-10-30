require "pathname"
require "fileutils"

module Sitepress
  # Compile all resources from a Sitepress site into static pages.
  class Compiler
    include FileUtils

    def initialize(site: )
      @site = site
    end

    # Iterates through all pages and writes them to disk
    def compile(target_path:)
      target_path = Pathname.new(target_path)
      # TODO: Should file operations go here? Probably not.
      mkdir_p target_path
      root = Pathname.new("/")
      puts "Compiling #{@site.root_path.expand_path}"
      @site.resources.each do |resource|
        # These are root `resource.request_path`
        derooted = Pathname.new(resource.request_path).relative_path_from(root)
        path = target_path.join(derooted)
        mkdir_p path.dirname
        puts "  #{path}"
        File.open(path.expand_path, "w"){ |f| f.write render(resource) }
      end
      puts "Successful compilation to #{target_path.expand_path}"
    end

    private
    def render(resource)
      # TODO: Lets slim this down a bit.
      helpers = HelperLoader.new paths: Dir.glob(@site.root_path.join("helpers/**.rb"))
      context = helpers.context(locals: { current_page: resource, site: @site })
      ResourceRenderer.new(resource: resource).render(context: context)
    end
  end
end
