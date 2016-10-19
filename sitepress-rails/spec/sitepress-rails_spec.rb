require "spec_helper"
require "rails"
require "sitepress-rails"

describe Sitepress do
  context "default configuration" do
    subject{ Sitepress.configuration }
    it "has site" do
      expect(subject.site.root_path).to eql(Rails.root.join("app/content"))
    end
    it "has Rails.application as parent engine" do
      expect(subject.parent_engine).to eql(Rails.application)
    end
    it "has Rails.application as parent engine" do
      expect(subject.cache_resources).to be true
    end
    it "has routes enabled by default" do
      expect(subject.routes).to be true
    end
  end
  context "Rails.configuration.paths" do
    subject { Rails.configuration.paths[path].to_a }
    context "views" do
      let(:path) { "app/views" }
      it { should include(Sitepress.site.root_path.to_s) }
    end
    context "helpers" do
      let(:path) { "app/helpers" }
      it { should include(Sitepress.site.root_path.join("helpers").to_s) }
    end
    context "assets" do
      let(:path) { "app/assets" }
      it { should include(Sitepress.site.root_path.join("assets").to_s) }
    end
  end
end
