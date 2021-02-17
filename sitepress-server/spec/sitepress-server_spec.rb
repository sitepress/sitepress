require "spec_helper"
require "rack/test"
require 'sitepress-server'

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  before {  }

  def app
    Sitepress.configuration.site = site
    Sitepress::Server.boot
  end

  let(:request_path) { "/test" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
