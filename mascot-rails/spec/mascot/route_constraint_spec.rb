require "spec_helper"

describe Mascot::RouteConstraint do
  let(:sitemap) { Mascot::Sitemap.new(root_dir: "spec/pages") }
  let(:route_constraint) { Mascot::RouteConstraint.new(sitemap) }

  context "#matches?" do
    it "returns true if match" do
      request = double("request", path: "/test")
      expect(route_constraint.matches?(request)).to be(true)
    end
    it "returns false if not match" do
      request = double("request", path: "/does-not-exist")
      expect(route_constraint.matches?(request)).to be(false)
    end
  end
end
