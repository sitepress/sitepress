require_relative "benchmark_helper"

require "rack/test"
page_count = 10_000

title "Rails requests for #{page_count} asset site"

# Verifies that a non-200 response isn't mistaken as a valid benchmark. We call
# the request multiple times so we can measure reloading the entire site between
# requests in a development environment.
def get!(path, number_of_requests: 5)
  number_of_requests.times do
    resp = get(path)
    fail "GET #{path.inspect} - HTTP #{resp.status} resp\n---\n#{resp.body}\n---" if resp.status != 200
    resp
  end
end

fake_site do |site|
  site.generate_pages(count: page_count) do |path|
    path = [path,".erb"].join
    File.write path, """---
title: The page #{path}
---
<h1>There are <%= pluralize site.resources.size, 'page' %> in the site<h1>
<p>And they are...<p>
<ul>
<% site.resources.each do |r| %>
  <li><%= link_to r.data['title'], r.request_path %></li>
<% end %>
</ul>"""
  end

  initialize_rails do
    # Setup rails to use the fake site.
    Sitepress.configure do |config|
      config.site = site.site
    end
  end

  site = Sitepress.site
  resources = Sitepress.site.resources
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
    Sitepress.configuration.cache_resources = caching

    benchmark "Rails #{Rails.env} environment (Sitepress.configuration.cache_resources = #{caching})" do |x|
      x.report "Sitepress.configuration.resources.get(#{path.inspect})" do
        Sitepress.site.resources.get path
      end

      rails_request = Struct.new(:path).new(path)
      route_constraint = Sitepress::RouteConstraint.new(site: Sitepress.site)
      x.report "Sitepress::RouteConstraint#match?" do
        route_constraint.matches? rails_request
      end

      x.report "GET /baseline/render (simple text render)" do
        get! "/baseline/render"
      end

      [path, last_path].each do |request_path|
        x.report "GET #{request_path} (complex erb render)" do
          get! request_path
        end
      end
    end
  end
end
