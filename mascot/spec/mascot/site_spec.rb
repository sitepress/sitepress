require "spec_helper"

context Mascot::Site do
  subject { Mascot::Site.new(root_path: "spec/pages") }
  let(:resource_count) { 5 }
  it "has 5 resources" do
    expect(subject.root.to_a.size).to eql(resource_count)
  end
  context "#glob" do
    it "globs resources" do
      expect(subject.glob("*sin_frontmatter*").size).to eql(1)
    end
  end
  describe "#manipulate" do
    it "adds ProcManipulator to_pipeline" do
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
