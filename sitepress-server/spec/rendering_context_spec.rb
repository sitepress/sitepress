require "spec_helper"
require 'sitepress-server'

describe Sitepress::AssetRenderer do
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  let(:resource) { site.get(request_path) }
  subject { Sitepress::RenderingContext.new(resource: resource, site: site) }

  context "block rendering" do
    context "haml" do
      let(:request_path) { "nested_haml_layout.html" }
      it "renders" do
        expect(subject.render).to eql("")
      end
    end

    context "erb" do
      let(:request_path) { "nested_erb_layout.html" }
      it "renders" do
        expect(subject.render).to eql("")
      end
    end
  end
end
