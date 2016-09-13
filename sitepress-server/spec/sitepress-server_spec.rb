require "spec_helper"
require "rack/test"
require 'sitepress-server'

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }

  def app
    Sitepress::Server.new(site: site)
  end

  let(:request_path) { "/test.html" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
