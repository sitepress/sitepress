require "spec_helper"

context Sitepress::Site do
  subject { Sitepress::Site.new(root_path: "spec/sites/sample") }
  let(:resource_count) { 6 }
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

    it "has helpers_path" do
      expect(subject.helpers_path.to_s).to eql("spec/sites/sample/helpers")
    end

    it "has assets_path" do
      expect(subject.assets_path.to_s).to eql("spec/sites/sample/assets")
    end

    it "has models_path" do
      expect(subject.models_path.to_s).to eql("spec/sites/sample/models")
    end

    describe "setters" do
      it "sets pages_path" do
        subject.pages_path = "/custom/pages"
        expect(subject.pages_path.to_s).to eql("/custom/pages")
      end

      it "sets helpers_path" do
        subject.helpers_path = "/custom/helpers"
        expect(subject.helpers_path.to_s).to eql("/custom/helpers")
      end

      it "sets assets_path" do
        subject.assets_path = "/custom/assets"
        expect(subject.assets_path.to_s).to eql("/custom/assets")
      end

      it "sets models_path" do
        subject.models_path = "/custom/models"
        expect(subject.models_path.to_s).to eql("/custom/models")
      end
    end
  end

  describe "#reload!" do
    it "clears cached resources" do
      original_resources = subject.resources
      subject.reload!
      expect(subject.resources).to_not be(original_resources)
    end

    it "clears cached root" do
      original_root = subject.root
      subject.reload!
      expect(subject.root).to_not be(original_root)
    end

    it "returns self" do
      expect(subject.reload!).to be(subject)
    end
  end

  describe "#resources_pipeline=" do
    it "sets custom pipeline" do
      custom_pipeline = Sitepress::ResourcesPipeline.new
      subject.resources_pipeline = custom_pipeline
      expect(subject.resources_pipeline).to be(custom_pipeline)
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
    it "manipulates resources" do
      subject.manipulate do |root|
        root.get("blog/my-awesome-post").node = root.child("my-awesome-post")
      end
      expect(subject.get("my-awesome-post").asset.path.to_s).to eql("spec/sites/sample/pages/blog/my-awesome-post.html.md")
    end
  end
  describe "#delete" do
    it "removes node" do
      expect{subject.get("blog/my-awesome-post").remove}.to change{subject.resources.size}.by(-1)
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
  describe "#dig" do
    it "finds resource" do
      expect(subject.dig("blog", "my-awesome-post").format(:html)).to eql subject.get("/blog/my-awesome-post.html")
    end
  end
end
