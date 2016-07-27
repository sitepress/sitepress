require_relative "./fake_site_generator"

module Mascot
  # Make writing benchmarks a little easier.
  module BenchmarkDSL
    def desc(text)
      puts "\n\n## #{text}\n\n"
    end
    def title(text)
      puts "\n# #{text} "
    end

    # Generates a fake website.
    def fake_site(page_count: nil)
      site = Mascot::FakeSiteGenerator.new
      begin
        site.generate_pages(count: page_count) if page_count
        yield site
      ensure
        site.delete
      end
    end
  end
end
