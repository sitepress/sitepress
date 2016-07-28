require_relative "benchmark_helper"

page_count = 10_000
title "Benchmarks for #{page_count} page website"

fake_site do |site|
  site.generate_pages(count: page_count)
  sitemap = site.sitemap
  resources = sitemap.resources
  path = resources.last.request_path

  benchmark "Builds all resources from scratch" do |x|
    x.report "Sitemap#resources" do
      sitemap.resources
    end
    x.report "Sitemap#get" do
      sitemap.get path
    end
  end
end
