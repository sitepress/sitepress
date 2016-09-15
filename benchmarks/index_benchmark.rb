require_relative "benchmark_helper"

page_count = 10_000
title "Benchmarks for #{page_count} page website"

fake_site do |fake|
  fake.generate_pages(count: page_count)
  site = fake.site
  resources = site.resources
  path = resources.to_a.last.request_path

  benchmark "Builds all resources from scratch" do |x|
    x.report "Site#resources" do
      site.root
    end
    x.report "Site#get" do
      site.get path
    end
  end
end
