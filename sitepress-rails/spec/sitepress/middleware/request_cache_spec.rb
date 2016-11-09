require "spec_helper"

describe Sitepress::Middleware::RequestCache do
  let(:site) { instance_double("Sitepress::Site") }
  let(:app) { double }
  let(:middleware) { Sitepress::Middleware::RequestCache.new(app, site: site)}
  it "sets Site#cache_resources back to original value" do
    expect(site).to receive(:cache_resources).and_return(false).ordered
    expect(site).to receive(:cache_resources=).with(true).ordered
    expect(app).to receive(:call).and_raise("boom").ordered
    expect(site).to receive(:cache_resources=).with(false).ordered
    expect{ middleware.call({}) }.to raise_error("boom")
  end
end