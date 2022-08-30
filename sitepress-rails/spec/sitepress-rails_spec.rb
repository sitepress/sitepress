require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  let(:app) { Rails.application }
  subject { Sitepress.configuration }

  it "has Rails.application as parent engine" do
    expect(subject.parent_engine).to eql(app)
  end
end
