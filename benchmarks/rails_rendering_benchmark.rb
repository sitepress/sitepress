require_relative "benchmark_helper"

require "rack/test"
page_count = 10_000
title "Rails requests for #{page_count} asset site"

# Verifies that a non-200 response isn't mistaken as a valid benchmark.
def get!(path)
  resp = get(path)
  status, _, body = resp
  fail "GET #{path.inspect} - HTTP #{status} resp\n---\n#{body.body}\n---" if status != 200
  resp
end

fake_site do |site|
  site.generate_pages(count: page_count)
  initialize_rails do
    # Setup rails to use the fake site.
    Mascot.configure do |config|
      config.sitemap = site.sitemap
    end
  end
  sitemap = Mascot.configuration.sitemap
  resources = sitemap.resources

  include Rack::Test::Methods

  # I've verified this is only loaded once, then memized
  # by rack/test in subsquent calls.
  def app
    Rails.application
  end

  benchmark "Rails #{Rails.env} environment GET requests" do |x|
    path = resources.first.request_path
    # For comparision to getting the path.
    x.report "Mascot.configuration.sitemap.get(#{path.inspect})" do
      Mascot.configuration.sitemap.resources.get path
    end

    x.report "GET /baseline/render" do
      get! "/baseline/render"
    end

    x.report "GET #{path}" do
      get! path
    end
  end
end
