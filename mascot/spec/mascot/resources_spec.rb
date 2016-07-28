require "spec_helper"

context Mascot::Resources do
  subject { Mascot::Resources.new(root_file_path: root) }
  let(:root) { "spec/pages" }
  let(:asset) { Mascot::Asset.new(path: "spec/pages/test.html.haml")}
  let(:resource) { Mascot::Resource.new(request_path: "/test", asset: asset) }

  context "#add resource" do
    before { subject.add resource }
    it "#size" do
      expect(subject.size).to eql(1)
    end
    it "gets resource" do
      expect(subject.get("/test")).to eql(resource)
    end
    it "raises Mascot::InvalidRequestPathError if nil" do
      expect{subject.add(nil)}.to raise_exception(Mascot::InvalidRequestPathError)
    end
    it "raises Mascot::ExistingRequestPathError" do
      expect{subject.add(resource.clone)}.to raise_exception(Mascot::ExistingRequestPathError)
    end
    context "change Resource#request_path" do
      before { resource.request_path = "/diff" }
      it "#get new path" do
        expect(subject.get("/diff")).to eql(resource)
      end
      it "does not #get old path" do
        expect(subject.get("/test")).to be_nil
      end
    end
    context "clone Resource" do
      let(:copy) { resource.clone }
      before do
        copy.request_path = "/clone"
      end
      it "does not #get new path" do
        expect(subject.get("/clone")).to be_nil
      end
      it "#get old path" do
        expect(subject.get("/test")).to eql(resource)
      end
      context "add to Resouces" do
        before { subject.add copy }
        it "#get new path" do
          expect(subject.get("/clone")).to eql(copy)
        end
        it "#get old path" do
          expect(subject.get("/test")).to eql(resource)
        end
        it "#last" do
          expect(subject.last).to eql(copy)
        end
        it "#first" do
          expect(subject.first).to eql(resource)
        end
      end
    end
    context "#remove resource" do
      before{ subject.remove resource }
      it "#size" do
        expect(subject.size).to be_zero
      end
      it "doest not get resource" do
        expect(subject.get("/test")).to be_nil
      end
      it "raises InvalidRequestPathError if nil" do
        expect{subject.remove(nil)}.to raise_exception(Mascot::InvalidRequestPathError)
      end
    end
  end
end
