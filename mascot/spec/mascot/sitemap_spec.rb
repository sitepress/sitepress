require "spec_helper"

context Mascot::Sitemap do
  subject { Mascot::Sitemap.new(root: "spec/pages") }
  let(:resource_count) { 4 }
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
    context "proxy" do
      context "data" do
        before { subject.proxy.single_resource{ |r| r.data["changed"] = true } }
        it "adds data" do
           expect(subject.get("/test").data["changed"]).to be true
        end
      end
      context "request_path" do
        before { subject.proxy.single_resource{ |r| r.request_path = File.join("/more", r.request_path) } }
        it "does not find original" do
           expect(subject.get("/test")).to be_nil
        end
        it "finds renamed" do
           expect(subject.get("/more/test")).to_not be_nil
        end
      end
      context "manipulate all assets" do
        before do
          subject.proxy.all_resources do |resources|
            resources.glob("*test*").each do |resource|
              resources.add resource.clone.tap{ |r| r.request_path = File.join("/more", r.request_path) }
            end
          end
        end
        it "finds /more/test" do
          expect(subject.get("/more/test")).to_not be_nil
        end
        it "finds /test" do
          expect(subject.get("/test")).to_not be_nil
        end
        it "globs two test resources" do
          expect(subject.resources.glob("*test*").size).to eql(2)
        end
      end
    end
  end
end
