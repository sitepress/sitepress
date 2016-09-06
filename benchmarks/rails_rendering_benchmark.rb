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
<h1>There are <%= pluralize resources.to_a.size, 'page' %> in the site<h1>
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
      config.site = site.site
    end
  end

  site = Mascot.configuration.site
  root = Mascot.configuration.root
  resources = root.resources
  path = resources.first.request_path
  last_path = resources.to_a.last.request_path

  include Rack::Test::Methods

  # I've verified this is only loaded once, then memized
  # by rack/test in subsquent calls.
  def app
    Rails.application
  end

  # Test caching configurations.
  [true,false].each do |caching|
    Mascot.configuration.cache_resources = caching

    benchmark "Rails #{Rails.env} environment (Mascot.configuration.cache_resources = #{caching})" do |x|
      x.report "Mascot.configuration.resources.get(#{path.inspect})" do
        Mascot.configuration.root.get path
      end

      rails_request = Struct.new(:path).new(path)
      route_constraint = Mascot::RouteConstraint.new(root: Mascot.configuration.root)
      x.report "Mascot::RouteConstraint#match?" do
        route_constraint.matches? rails_request
      end

      x.report "GET /baseline/render (simple text render)" do
        get! "/baseline/render"
      end

      [path, last_path].each do |path|
        x.report "GET #{path} (complex erb render)" do
          get! path
        end
      end
    end
  end
end
