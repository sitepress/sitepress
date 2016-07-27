require_relative "benchmark_helper"

page_count = 10_000
fake_site = Mascot::FakeSiteGenerator.new
samples = 30

def desc(text)
  puts "\n\n== #{text}\n\n"
end

puts "Benchmarks for #{page_count} page website\n\n"

begin
  fake_site.generate_pages(count: page_count)
  sitemap = Mascot::Sitemap.new(file_path: fake_site.dir)
  resources = sitemap.resources
  last_page = "/page-1"
  first_page = "/page-#{page_count}"

  desc "Builds all resources from scratch"
  Benchmark.bmbm do |x|
    x.report "Sitemap#resources" do
      sitemap.resources
    end
  end

  desc "Builds an index from an existing collection of resources"
  Benchmark.bmbm do |x|
    # Disk index takes longer to build, but uses less memory in
    # a server environment that can warm-up/build the index.
    x.report "DiskIndex#index" do
      Mascot::DiskIndex.new.index resources
    end
    # Memory index builds faster, but takes up more memory. Best suited
    # for a develoment environment.
    x.report "MemoryIndex#index" do
      Mascot::MemoryIndex.new.index resources
    end
  end

  desc "Requests the first and last resource from the collection"
  Benchmark.bmbm do |x|
    # Create the indicies
    disk_index = Mascot::DiskIndex.new
    disk_index.index resources

    memory_index = Mascot::MemoryIndex.new
    memory_index.index resources

    [first_page, last_page].each do |path|
      x.report "Sitemap#find_by_request_path(#{path.inspect})" do
        sitemap.find_by_request_path(path)
      end

      x.report "DiskIndex#get(#{path.inspect})" do
        disk_index.get(path)
      end

      x.report "MemoryIndex#get(#{path.inspect})" do
        memory_index.get(path)
      end
    end
  end

ensure
  fake_site.delete
end
