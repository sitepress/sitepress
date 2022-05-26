require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  let(:app) { Rails.application }
  subject { Sitepress.configuration }

  it "has Rails.application as parent engine" do
    expect(subject.parent_engine).to eql(app)
  end

  describe "Sitepress::Path.template_extensions" do
    subject { Sitepress::Path.handler_extensions }
    it { is_expected.to eql ActionView::Template::Handlers.extensions }
    it { is_expected.to_not be_empty }
  end
end
