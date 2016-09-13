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
    it "has routes enabled by default" do
      expect(subject.routes).to be true
    end
  end
  it "prepends Site#root_path to ActionController::Base.view_paths" do
    expect(ActionController::Base.view_paths.first.to_s).to eql(Sitepress.site.root_path.to_s)
  end
end
