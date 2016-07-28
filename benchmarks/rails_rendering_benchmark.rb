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
  site.generate_pages(count: page_count) do |path|
    path = [path,".erb"].join
    File.write path, """---
title: The page #{path}
---
<h1>There are <%= pluralize resources.size, 'page' %> in the site<h1>
<p>And they are...<p>
<ul>
<% resources.each do |r| %>
  <li><%= link_to r.data['title'], r.request_path %></li>
<% end %>
</ul>"""
  end

  initialize_rails do
    # Setup rails to use the fake site.
    Mascot.configure do |config|
      config.sitemap = site.sitemap
    end
  end

  sitemap = Mascot.configuration.sitemap
  resources = Mascot.configuration.resources
  path = resources.first.request_path

  include Rack::Test::Methods

  # I've verified this is only loaded once, then memized
  # by rack/test in subsquent calls.
  def app
    Rails.application
  end

  # Test caching configurations.
  [true,false].each do |caching|
    Mascot.configuration.cache_resources = caching

    benchmark "Rails #{Rails.env} environment GET requests (Mascot.configuration.cache_resources = #{caching})" do |x|
      x.report "Mascot.configuration.resources.get(#{path.inspect})" do
        Mascot.configuration.resources.get path
      end

      rails_request = Struct.new(:path).new(path)
      route_constraint = Mascot::RouteConstraint.new(resources: Mascot.configuration.resources)
      x.report "Mascot::RouteConstraint#match?" do
        route_constraint.matches? rails_request
      end

      x.report "GET /baseline/render" do
        get! "/baseline/render"
      end

      x.report "GET #{path}" do
        get! path
      end
    end
  end
end
