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

    # Format in Markdown for easier sharing.
    def benchmark(title = nil, &block)
      puts "\n## #{title}\n\n\n```\n" if title
      Benchmark.bmbm(&block)
      puts "```"
    end

    # Huge PIA to latch into the correct boot sequences for rails. This deals with
    # it all. Pass a block of stuff you want to setup *before* rails boots.
    def initialize_rails(&block)
      # Setup the fucking rails instance. What a side-affect loaded pile of shit.
      ENV["RAILS_ENV"] = "production"
      require_relative "../mascot-rails/spec/dummy/config/application"
      require "mascot/rails"

      # Likely a Mascot setup going on in here.
      block.call Rails.application if block_given?

      # Initialize the Rails application.
      Rails.application.initialize!

      # Its pointless benchmarking a non-production rails app because
      # of all the class reloading performance.
      fail "Rails environment not set to production" unless Rails.env.production?
    end
  end
end
