require "spec_helper"

describe Sitepress::RouteConstraint do
  let(:subject) { Sitepress::RouteConstraint.new(site: Sitepress.configuration.site) }

  context "#matches?" do
    it "returns true if match" do
      request = double("request", path: "/time")
      expect(subject.matches?(request)).to be(true)
    end
    it "returns false if not match" do
      request = double("request", path: "/does-not-exist")
      expect(subject.matches?(request)).to be(false)
    end
  end
end
