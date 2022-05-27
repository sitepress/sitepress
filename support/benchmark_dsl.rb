require_relative "./fake_site_generator"

module Sitepress
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
      fake = Sitepress::FakeSiteGenerator.new
      begin
        fake.generate_pages(count: page_count) if page_count
        yield fake
      ensure
        fake.delete
      end
    end

    # Format in Markdown for easier sharing.
    def benchmark(title = nil, &block)
      puts "\n## #{title}\n\n\n```\n" if title
      Benchmark.bmbm(&block)
      puts "```"
    end
  end
end
