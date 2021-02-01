require "spec_helper"

context Sitepress::Site do
  subject { Sitepress::Site.new(root_path: "spec/sites/sample") }
  let(:resource_count) { 5 }
  it "has 5 resources" do
    expect(subject.resources.to_a.size).to eql(resource_count)
  end
  describe "paths" do
    it "has root_path" do
      expect(subject.root_path.to_s).to eql("spec/sites/sample")
    end

    it "has pages_path" do
      expect(subject.pages_path.to_s).to eql("spec/sites/sample/pages")
    end
  end
  context "#glob" do
    it "globs resources" do
      expect(subject.glob("sin_frontmatter*").size).to eql(1)
    end
    context "ignores swap files" do
      let(:path) { "spec/sites/sample/pages/text.txt#{ext}" }
      describe "ending with ~" do
        let(:ext) { "~" }
        it "exists" do
          expect(File.exist?(path)).to be true
        end
        it "is not in site resources" do
          expect(subject.resources.map{ |r| r.asset.path.to_s }).to_not include(path)
        end
      end
      describe "ending with .swp" do
        let(:ext) { ".swp" }
        it "exists" do
          expect(File.exist?(path)).to be true
        end
        it "is not in site resources" do
          expect(subject.resources.map{ |r| r.asset.path.to_s }).to_not include(path)
        end
      end
    end
  end
  describe "#manipulate" do
    it "adds ProcManipulator to_pipeline" do
      subject.manipulate { |resource, resources| }
      expect(subject.resources_pipeline.last).to be_instance_of(Sitepress::Extensions::ProcManipulator)
    end
  end
  describe "#get" do
    it "finds with leading /" do
      expect(subject.get("/test")).to_not be_nil
    end
    it "finds without leading /" do
      expect(subject.get("test")).to_not be_nil
    end
    it "finds nil" do
      expect(subject.get(nil)).to be_nil
    end
    it "does not traverse directories" do
      expect(subject.get("/../pages/test")).to be_nil
    end
  end
end
