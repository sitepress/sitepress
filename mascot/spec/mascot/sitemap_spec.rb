require "spec_helper"

context Mascot::Sitemap do
  subject { Mascot::Sitemap.new(root: "spec/pages") }
  let(:resource_count) { 5 }
  it "has 3 resources" do
    expect(subject.resources.size).to eql(resource_count)
  end
  context "#glob" do
    it "globs resources" do
      expect(subject.resources.glob("*sin_frontmatter*").size).to eql(1)
    end
    it "raises exception for glob outside of sitemap root" do
      expect{subject.resources.glob("./..")}.to raise_exception(Mascot::UnsafePathAccessError)
    end
  end
  describe "#manipulate" do
    it "adds ProcManipulator to resources_pipeline" do
      subject.manipulate { |resource, resources| }
      expect(subject.resources_pipeline.last).to be_instance_of(Mascot::Extensions::ProcManipulator)
    end
  end
  describe "#get" do
    it "finds with leading /" do
      expect(subject.get("/test.html")).to_not be_nil
    end
    it "finds without leading /" do
      expect(subject.get("test.html")).to_not be_nil
    end
    it "finds nil" do
      expect(subject.get(nil)).to be_nil
    end
    it "does not traverse directories" do
      expect(subject.get("/../pages/test")).to be_nil
    end
  end
end
