require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  let(:app) { Rails.application }
  subject { Sitepress.configuration }

  it "has Rails.application as parent engine" do
    expect(subject.parent_engine).to eql(app)
  end
  it "sets Sitepress::Path.template_extensions" do
    expect(Sitepress::Path.handler_extensions).to eql ActionView::Template::Handlers.extensions
  end
end
