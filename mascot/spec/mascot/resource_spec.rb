require "spec_helper"

context Mascot::Resource do
  subject { Mascot::Resource.new(file_path: "spec/pages/test.html.haml", request_path: "/test") }
  it "has data" do
    expect(subject.data["title"]).to eql("Name")
  end
  it "parses body" do
    expect(subject.body).to include("This is just some content")
  end
  context "content types" do
    context "format and template" do
      subject { Mascot::Resource.new(file_path: "spec/pages/test.html.haml", request_path: "/test") }
      describe "#extensions" do
        it "returns [html, haml]" do
          expect(subject.extensions).to eql(%w[html haml])
        end
      end
      describe "#format_extension" do
        it "returns 'html'" do
          expect(subject.format_extension).to eql("html")
        end
      end
      describe "#template_extensions" do
        it "returns [haml]" do
          expect(subject.template_extensions).to eql(%w[haml])
        end
      end
      describe "#mime_type" do
        it "has html mime type" do
          expect(subject.mime_type).to eql(MIME::Types["text/html"].first)
        end
      end
    end
    context "format" do
      subject { Mascot::Resource.new(file_path: "spec/pages/text.txt", request_path: "/text") }
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
        it "has plain mime type" do
          expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
        end
      end
    end
    context "none" do
      subject { Mascot::Resource.new(file_path: "spec/pages/nothing", request_path: "/nothing") }
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
      describe "#mime_type" do
        it "is application/octet-stream" do
          expect(subject.mime_type).to eql(MIME::Types["application/octet-stream"].first)
        end
      end
    end
    context "mime type override " do
      subject { Mascot::Resource.new(file_path: "spec/pages/nothing", request_path: "/nothing", mime_type: MIME::Types["text/plain"]) }
      it "is text/plain" do
        expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
      end
    end
  end
end
