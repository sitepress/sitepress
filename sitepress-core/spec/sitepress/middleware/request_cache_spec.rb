require "spec_helper"

describe Sitepress::Middleware::RequestCache do
  let(:site) { instance_double("Sitepress::Site") }
  let(:app) { double }
  let(:middleware) { Sitepress::Middleware::RequestCache.new(app, site: site)}
  describe "Site#cache_resources=false" do
    it "resets value and clears cache" do
      expect(site).to receive(:cache_resources).and_return(false).ordered
      expect(site).to receive(:cache_resources=).with(true).ordered
      expect(app).to receive(:call).and_raise("boom").ordered
      expect(site).to receive(:cache_resources=).with(false).ordered
      expect(site).to receive(:cache_resources).and_return(false).ordered
      expect(site).to receive(:clear_resources_cache).ordered
      expect{ middleware.call({}) }.to raise_error("boom")
    end
  end
  describe "Site#cache_resources=true" do
    it "resets value and clears cache" do
      expect(site).to receive(:cache_resources).and_return(true).ordered
      expect(site).to receive(:cache_resources=).with(true).ordered
      expect(app).to receive(:call).and_raise("boom").ordered
      expect(site).to receive(:cache_resources=).with(true).ordered
      expect(site).to receive(:cache_resources).and_return(true).ordered
      expect(site).to_not receive(:clear_resources_cache).ordered
      expect{ middleware.call({}) }.to raise_error("boom")
    end
  end
end
