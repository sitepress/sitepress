require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  subject { Sitepress.configuration }
  let(:app) { Dummy::Application.new }
  let(:cache_classes) { false }
  before do
    app.config.eager_load = cache_classes # WTF?
  end
  it "has Rails.application as parent engine" do
    app.initialize!
    expect(subject.parent_engine).to eql(app)
  end
  it "has routes enabled by default" do
    app.initialize!
    expect(subject.routes).to be true
  end
end
