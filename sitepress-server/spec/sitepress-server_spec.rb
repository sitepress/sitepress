require "spec_helper"
require "rack/test"
require 'sitepress-server'

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }

  def app
    Sitepress::Server.new(site: site)
  end

  context "GET existing resource" do
    let(:request_path) { "/test.html" }
    before { get request_path }
    it "returns 200" do
      expect(last_response.status).to eql(200)
    end
  end

  context "GET non-existing resource" do
    let(:request_path) { "/does-not-exist.html" }
    before { get request_path }
    it "returns 404" do
      expect(last_response.status).to eql(404)
    end
  end
end
