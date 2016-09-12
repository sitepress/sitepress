require "spec_helper"

describe Sitepress::RailsConfiguration do
  subject { Sitepress::RailsConfiguration.new }
  context "#partials" do
    it "excludes partials" do
      expect(subject.site.resources.size).to eql(2)
    end
  end
end
