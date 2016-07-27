require "spec_helper"
require "rack/test"
require 'mascot-server'

describe Mascot::Server do
  include Rack::Test::Methods
  let(:sitemap) { Mascot::Sitemap.new(root: "spec/pages") }

  def app
    Mascot::Server.new(sitemap: sitemap)
  end

  let(:request_path) { "/test" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
