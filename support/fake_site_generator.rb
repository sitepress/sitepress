require "fileutils"
require "tmpdir"

module Sitepress
  class FakeSiteGenerator
    attr_reader :dir, :pages

    def initialize(dir: Dir.mktmpdir)
      @dir = Pathname.new(dir)
      @pages = Array.new
    end

    # Generates pages in the site's root URL
    def generate_pages(count: , &block)
      FileUtils.mkdir_p @dir
      next_page_name.take(count).map do |page_name|
        path = @dir.join(page_name)
        block ? block.call(path) : File.write(path, '<h1>Some glorius content!</h1>')
        @pages.push path
      end
    end

    def delete
      FileUtils.mkdir_p @dir
      @pages.clear
    end

    def site
      Sitepress::Site.new(root_path: @dir)
    end

    private
    def next_page_name
      @next_page_name ||= Enumerator.new do |yielder|
        count = 0
        while count += 1 do
          yielder << "page-#{count}.html"
        end
      end
    end
  end
end
