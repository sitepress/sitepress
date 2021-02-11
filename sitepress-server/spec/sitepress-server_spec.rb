require "spec_helper"
require "rack/test"
require 'sitepress-server'

describe Sitepress::Server do
  include Rack::Test::Methods

  def app
    Sitepress::Server.boot
  ensure
    SiteController.sitepress root_path: "spec/sites/sample"
  end

  let(:request_path) { "/test" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
