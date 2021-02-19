require "spec_helper"
require "rack/test"
require 'sitepress-server'

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  before do
    Sitepress::Server.boot do |config|
      config.site = site
    end
  end

  def app
    Sitepress::Server
  end

  let(:request_path) { "/test" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
