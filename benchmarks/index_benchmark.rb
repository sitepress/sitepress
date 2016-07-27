require_relative "benchmark_helper"

page_count = 10_000
title "Benchmarks for #{page_count} page website"

fake_site do |site|
  site.generate_pages(count: page_count)
  sitemap = site.sitemap
  resources = sitemap.resources

  benchmark "Builds all resources from scratch" do |x|
    x.report "Sitemap#resources" do
      sitemap.resources
    end
  end

  benchmark "Builds an index from an existing collection of resources" do |x|
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

  benchmark "Requests the first and last resource from resource collection" do |x|
    # Create the indicies
    disk_index = Mascot::DiskIndex.new
    disk_index.index resources

    memory_index = Mascot::MemoryIndex.new
    memory_index.index resources

    [resources.first.request_path, resources.last.request_path].each do |path|
      x.report "Sitemap#get(#{path.inspect})" do
        sitemap.get(path)
      end

      x.report "DiskIndex#get(#{path.inspect})" do
        disk_index.get(path)
      end

      x.report "MemoryIndex#get(#{path.inspect})" do
        memory_index.get(path)
      end
    end
  end
end
