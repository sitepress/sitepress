require "spec_helper"
require "rack/test"
require 'sitepress'

describe Sitepress::Server do
  include Rack::Test::Methods
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  before do
    Sitepress.configure do |config|
      config.site = site
    end
  end

  after do
    Sitepress.reset_configuration
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
