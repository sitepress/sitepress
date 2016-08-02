require "spec_helper"

describe Mascot::Extensions::Layouts do
  subject { Mascot::Extensions::Layouts.new }
  let(:resources) { Mascot::Sitemap.new(root: "spec/pages").resources }
  let(:resource) { resources.first }
  before do
    subject.layout("blah-set-by-rspec"){ |r| r == resource }
    subject.process_resources resources
  end
  it "sets resource.data['layout'] key" do
    expect(resource.data['layout']).to eql("blah-set-by-rspec")
  end
end
