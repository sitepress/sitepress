require "spec_helper"

context Sitepress::Asset do
  let(:path) { "spec/pages/test.html.haml" }
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
  it "has haml template_extensions" do
    expect(subject.template_extensions).to eql(["haml"])
  end
  it "has html format_extension" do
    expect(subject.format_extension).to eql("html")
  end
  it "has basename.html" do
    expect(subject.format_basename).to eql("test.html")
  end
  it "has request_path" do
    expect(subject.to_request_path.to_s).to eql("spec/pages/test.html")
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
      describe "#extensions" do
        it "returns [txt]" do
          expect(subject.extensions).to eql(%w[txt])
        end
      end
      describe "#format_extension" do
        it "returns 'txt'" do
          expect(subject.format_extension).to eql("txt")
        end
      end
      describe "#template_extensions" do
        it "returns []" do
          expect(subject.template_extensions).to be_empty
        end
      end
      describe "#mime_type" do
        it "is text/plain" do
          expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
        end
      end
      it "#to_request_path" do
        expect(subject.to_request_path.to_s).to eql("spec/pages.ar-awesome is here/text.txt")
      end
    end
    context "none" do
      let(:path) { "spec/pages/nothing" }
      describe "#extensions" do
        it "is empty" do
          expect(subject.extensions).to be_empty
        end
      end
      describe "#format_extension" do
        it "is nil" do
          expect(subject.format_extension).to be_nil
        end
      end
      describe "#template_extensions" do
        it "is empty" do
          expect(subject.template_extensions).to be_empty
        end
      end
      it "#to_request_path" do
        expect(subject.to_request_path.to_s).to eql("spec/pages/nothing")
      end
    end
    context "overriden mime_type " do
      subject { Sitepress::Asset.new(path: path, mime_type: MIME::Types["text/plain"]) }
      it "is text/plain" do
        expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
      end
    end
  end
end
