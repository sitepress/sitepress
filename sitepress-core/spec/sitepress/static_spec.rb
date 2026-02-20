require "spec_helper"
require "tempfile"

RSpec.describe Sitepress::Static do
  describe "with a PDF file" do
    let(:pdf_data) { "%PDF-1.4 minimal pdf content" }

    let(:tempfile) do
      Tempfile.new(["document", ".pdf"]).tap do |f|
        f.binmode
        f.write(pdf_data)
        f.rewind
      end
    end

    subject { described_class.new(path: tempfile.path) }

    after { tempfile.close! }

    describe "#mime_type" do
      it "returns the MIME type" do
        expect(subject.mime_type.to_s).to eq("application/pdf")
      end
    end

    describe "#exists?" do
      it "returns true when file exists" do
        expect(subject.exists?).to be true
      end

      it "returns false when file doesn't exist" do
        static = described_class.new(path: "/nonexistent/file.pdf")
        expect(static.exists?).to be false
      end
    end

    describe "#body" do
      it "returns the raw binary content" do
        expect(subject.body).to eq(pdf_data)
      end
    end

    describe "#data" do
      it "returns empty managed data" do
        expect(subject.data.to_h).to eq({})
      end
    end

    describe "#inspect" do
      it "includes class name and path" do
        expect(subject.inspect).to match(/#<Sitepress::Static:0x[0-9a-f]+ path=/)
      end
    end
  end

  describe "with a WOFF2 font file" do
    let(:tempfile) do
      Tempfile.new(["roboto", ".woff2"]).tap do |f|
        f.binmode
        f.write("wOF2 font data")
        f.rewind
      end
    end

    subject { described_class.new(path: tempfile.path) }

    after { tempfile.close! }

    describe "#mime_type" do
      it "returns font/woff2" do
        expect(subject.mime_type.to_s).to eq("font/woff2")
      end
    end
  end

  describe "as a Resource source" do
    let(:tempfile) do
      Tempfile.new(["data", ".json"]).tap do |f|
        f.write('{"key": "value"}')
        f.rewind
      end
    end

    let(:static_asset) { described_class.new(path: tempfile.path) }
    let(:node) { Sitepress::Node.new }
    let(:resource) { Sitepress::Resource.new(source: static_asset, node: node.child("data"), format: :json) }

    after { tempfile.close! }

    it "has_data? returns true" do
      expect(resource.has_data?).to be true
    end

    it "data is empty hash" do
      expect(resource.data.to_h).to eq({})
    end

    it "renderable? returns false" do
      expect(resource.renderable?).to be false
    end

    it "source#inspect shows path" do
      expect(resource.source.inspect).to include("path=")
    end

    it "resource#inspect shows nested source inspect" do
      expect(resource.inspect).to include("source=#<Sitepress::Static:")
    end
  end
end
