require "fileutils"
require "tmpdir"

module Mascot
  class FakeSiteGenerator
    attr_reader :dir, :pages

    def initialize(dir: Dir.mktmpdir)
      @dir = Pathname.new(dir)
      @pages = pages
    end

    def generate_pages(count: )
      FileUtils.mkdir_p @dir
      next_page_name.take(count).each do |page_name|
        File.write(@dir.join(page_name), '<h1>Some glorius content!</h1>')
      end
    end

    def delete
      FileUtils.mkdir_p @dir
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
