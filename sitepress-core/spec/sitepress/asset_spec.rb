require "spec_helper"

context Sitepress::Asset do
  let(:path) { "spec/sites/sample/pages/test.html.haml" }
  subject { Sitepress::Asset.new(path: path) }

  it "has data" do
    expect(subject.data["title"]).to eql("Name")
  end
  it "is == with same path" do
    expect(subject == Sitepress::Asset.new(path: path)).to be true
  end
  it "parses body" do
    expect(subject.body).to include("This is just some content")
  end
  context "#exists?" do
    it "is true" do
      expect(subject.exists?).to be true
    end
    context "doesn't exist" do
      let(:path) { "/hi/friend" }
      it "is false" do
        expect(subject.exists?).to be false
      end
    end
  end

  context "content types" do
    context "format" do
      let(:path) { "spec/pages.ar-awesome is here/text.txt" }
      describe "#mime_type" do
        it "is text/plain" do
          expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
        end
      end
    end
    context "none" do
      let(:path) { "spec/pages/nothing" }
    end
    context "overriden mime_type " do
      subject { Sitepress::Asset.new(path: path, mime_type: MIME::Types["text/plain"]) }
      it "is text/plain" do
        expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
      end
    end
  end
end
