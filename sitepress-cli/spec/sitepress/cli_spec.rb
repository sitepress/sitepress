require "spec_helper"
require "rack"

Sitepress::Server = Class.new

describe Sitepress::CLI do
  let(:cli) { Sitepress::CLI.new }
  let(:app) { double("app", config: double("config", enable_site_error_reporting: nil, enable_site_reloading: nil)) }

  describe "#server" do
    let(:options) { { "port" => 3000, "bind_address" => "0.0.0.0", "site_reloading" => true, "site_error_reporting" => true } }

    before do
      allow(cli).to receive(:options).and_return(options)
      allow(cli).to receive(:initialize!).and_yield(app)
      allow(Rack::Server).to receive(:start)
    end

    it "runs the preview server with the correct options" do
      allow(app.config).to receive(:enable_site_error_reporting=).with(true)
      allow(app.config).to receive(:enable_site_reloading=).with(true)
      expect(Rack::Server).to receive(:start).with(hash_including(app: Sitepress::Server, Port: 3000, Host: "0.0.0.0"))
      cli.server
    end
  end

  context "#compile" do
    let(:args) { %w[-c spec/sites/sample/site.rb -o spec/sites/sample/build] }
    it "calls compiler"
  end

  context "#new" do
    let(:args) { %w[-t default spec/sites/new_site] }
    it "calls new"
  end
end
