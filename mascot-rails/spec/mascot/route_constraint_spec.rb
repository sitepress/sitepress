require "spec_helper"

describe Mascot::RouteConstraint do
  let(:subject) { Mascot::RouteConstraint.new }

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
