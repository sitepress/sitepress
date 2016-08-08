require "spec_helper"
require "rack/test"
require 'mascot-server'

describe Mascot::Server do
  include Rack::Test::Methods
  let(:site) { Mascot::Site.new(root: "spec/pages") }

  def app
    Mascot::Server.new(site: site)
  end

  let(:request_path) { "/test.html" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
