require "spec_helper"
require "rack/test"

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/server_sample") }
  before do
    Sitepress.configure do |config|
      config.site = site
    end
  end

  def app
    @app ||= Sitepress::Server.initialize!
  end

  let(:request_path) { "/test" }

  it "gets page" do
    get request_path
    expect(last_response.status).to eql(200)
  end
end
