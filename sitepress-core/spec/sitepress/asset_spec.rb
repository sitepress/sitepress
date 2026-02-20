require "spec_helper"

context Sitepress::Asset do
  let(:path) { "spec/sites/sample/pages/test.html.haml" }
  subject { Sitepress::Asset.new(path: path) }

  it "has data" do
    expect(subject.data["title"]).to eql("Name")
  end

  describe "#fetch_data" do
    it "returns data for existing key" do
      expect(subject.fetch_data(:title)).to eql("Name")
    end

    it "raises KeyError with file path for missing key" do
      expect { subject.fetch_data(:nonexistent) }.to raise_error(KeyError, /nonexistent.*#{Regexp.escape(path)}/)
    end
  end
  it "is == with same path" do
    expect(subject == Sitepress::Asset.new(path: path)).to be true
  end
  it "parses body" do
    expect(subject.body).to include("This is just some content")
  end
  it "renders file" do
    expect(subject.render).to eql(File.read subject.path)
  end
  it "saves file" do
    expect(subject.save)
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
      describe "#mime_type" do
        it "is text/plain" do
          expect(subject.mime_type).to eql(MIME::Types["application/octet-stream"].first)
        end
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
