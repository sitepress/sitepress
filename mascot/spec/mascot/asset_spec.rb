require "spec_helper"

context Mascot::Asset do
  let(:path) { "spec/pages/test.html.haml" }
  subject { Mascot::Asset.new(path: path) }

  it "has data" do
    expect(subject.data["title"]).to eql("Name")
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

  context "content types" do
    context "format" do
      let(:path) { "spec/pages/text.txt" }
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
    end
    context "overriden mime_type " do
      subject { Mascot::Asset.new(path: path, mime_type: MIME::Types["text/plain"]) }
      it "is text/plain" do
        expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
      end
    end
  end
end
