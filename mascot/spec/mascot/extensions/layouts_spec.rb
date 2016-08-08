require "spec_helper"
require "mascot/extensions/layouts"

describe Mascot::Extensions::Layouts do
  subject { Mascot::Extensions::Layouts.new }
  let(:resources) { Mascot::Site.new(root: "spec/pages").resources }
  let(:resource) { resources.first }
  before do
    subject.layout("blah-set-by-rspec"){ |r| r == resource }
    subject.process_resources resources
  end
  context "without layout in frontmatter" do
    it "sets resource.data['layout'] key" do
      expect(resource.data['layout']).to eql("blah-set-by-rspec")
    end
  end
  context "with layout in frontmatter" do
    let(:resource) { resources.first.tap{ |r| r.data["layout"] = "kung-fu"} }
    it "does not set resource.data['layout'] key" do
      expect(resource.data['layout']).to eql("kung-fu")
    end
  end
end
