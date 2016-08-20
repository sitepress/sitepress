require "spec_helper"
require "mascot/extensions/layouts"

describe Mascot::Extensions::Layouts do
  subject { Mascot::Extensions::Layouts.new }
  let(:root) { Mascot::Site.new(root_path: "spec/pages").root }
  let(:resource) { root.resources.first }
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
    let(:resource) { root.resources.first.tap{ |r| r.data["layout"] = "kung-fu"} }
    it "does not set resource.data['layout'] key" do
      expect(resource.data['layout']).to eql("kung-fu")
    end
  end
end
