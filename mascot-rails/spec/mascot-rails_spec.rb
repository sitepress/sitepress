require "spec_helper"
require "rails"
require "mascot-rails"

describe Mascot do
  context "default configuration" do
    subject{ Mascot.configuration }
    it "has sitemap" do
      expect(subject.sitemap.root).to eql(Rails.root.join("app/pages"))
    end
    it "has Rails.application as parent engine" do
      expect(subject.parent_engine).to eql(Rails.application)
    end
    it "has routes enabled by default" do
      expect(subject.routes).to be true
    end
  end
end
