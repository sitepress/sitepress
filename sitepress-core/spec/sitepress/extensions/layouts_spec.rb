require "spec_helper"
require "sitepress/extensions/layouts"

describe Sitepress::Extensions::Layouts do
  subject { Sitepress::Extensions::Layouts.new }
  let(:root) { Sitepress::Site.new(root_path: "spec/sites/sample").root }
  let(:resource) { root.flatten.first }
  before do
    subject.layout("blah-set-by-rspec"){ |r| r == resource }
    subject.process_resources root
  end
  context "without layout in frontmatter" do
    it "sets resource.data['layout'] key" do
      expect(resource.data['layout']).to eql("blah-set-by-rspec")
    end
  end
  context "with layout in frontmatter" do
    let(:resource) { root.flatten.first.tap{ |r| r.data["layout"] = "kung-fu"} }
    it "does not set resource.data['layout'] key" do
      expect(resource.data['layout']).to eql("kung-fu")
    end
  end
end
