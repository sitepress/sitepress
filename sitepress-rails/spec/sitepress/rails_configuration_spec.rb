require "spec_helper"

describe Sitepress::RailsConfiguration do
  subject { Sitepress::RailsConfiguration.new }
  context "#partials" do
    it "excludes partials" do
      expect(subject.site.resources.size).to eql(2)
    end
  end
  context "#cache_resources" do
    context "Rails.configuration.cache_classes=true" do
      before { Rails.configuration.cache_classes = true }
      it "is true" do
        expect(subject.cache_resources).to  eql(true)
      end
    end
    context "Rails.configuration.cache_classes=false" do
      before { Rails.configuration.cache_classes = false }
      it "is false" do
        expect(subject.cache_resources).to  eql(false)
      end
    end
  end
end
