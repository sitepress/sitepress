require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  subject { Sitepress.configuration }
  let(:app) { Dummy::Application.new }
  let(:cache_classes) { false }
  before do
    app.config.eager_load = cache_classes # WTF?
  end
  it "has site" do
    app.initialize!
    expect(subject.site.root_path).to eql(app.root.join("app/content"))
  end
  it "has Rails.application as parent engine" do
    app.initialize!
    expect(subject.parent_engine).to eql(app)
  end
  it "has Rails.application as parent engine" do
    app.initialize!
    expect(subject.cache_resources).to be_nil
  end
  it "has routes enabled by default" do
    app.initialize!
    expect(subject.routes).to be true
  end
  context "#cache_resources" do
    before do
      app.config.cache_classes = cache_classes # This is what I really want to test.
    end
    context "Rails.configuration.cache_classes=true" do
      let(:cache_classes) { true }
      it "is true" do
        app.initialize!
        expect(subject.cache_resources).to eql(true)
      end
    end
    context "Rails.configuration.cache_classes=false" do
      let(:cache_classes) { false }
      it "is false" do
        app.initialize!
        expect(subject.cache_resources).to eql(false)
      end
    end
  end
  context "Rails.configuration.paths" do
    subject { Rails.configuration.paths[path].to_a }
    context "views" do
      let(:path) { "app/views" }
      it { should include(app.root.join("app/content").to_s) }
    end
    context "helpers" do
      let(:path) { "app/helpers" }
      it { should include(app.root.join("app/content/helpers").to_s) }
    end
    context "assets" do
      let(:path) { "app/assets" }
      it { should include(app.root.join("app/content/assets").to_s) }
    end
  end
  context "#partals" do
    it "excludes partials" do
      expect(subject.site.resources.size).to eql(2)
    end
  end
end