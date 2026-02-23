require "spec_helper"
require "tempfile"
require "fileutils"

RSpec.describe Sitepress::Page do
  let(:path) { "spec/sites/sample/pages/test.html.haml" }
  subject { described_class.new(path: path) }

  describe "#body_line_offset" do
    it "returns offset from parser when file exists" do
      expect(subject.body_line_offset).to be >= 1
    end

    context "when file does not exist" do
      let(:path) { "/nonexistent/file.html" }

      it "returns 1" do
        expect(subject.body_line_offset).to eq(1)
      end
    end
  end

  describe "#parser=" do
    it "clears cached data when parser is changed" do
      # Access data to cache it
      original_data = subject.data

      # Change parser
      subject.parser = Sitepress::Parsers::Base

      # Data should be re-parsed (empty for Base parser)
      expect(subject.data.to_h).to eq({})
    end

    it "clears cached body when parser is changed" do
      # Access body to cache it
      original_body = subject.body

      # Change parser - Base parser returns entire file as body
      subject.parser = Sitepress::Parsers::Base

      # Body should now include frontmatter since Base doesn't parse it
      expect(subject.body).to include("---")
    end
  end

  describe "#updated_at" do
    it "returns file modification time" do
      expect(subject.updated_at).to be_a(Time)
      expect(subject.updated_at).to eq(File.mtime(path))
    end
  end

  describe "#created_at" do
    it "returns file creation time" do
      expect(subject.created_at).to be_a(Time)
      expect(subject.created_at).to eq(File.ctime(path))
    end
  end

  describe "#destroy" do
    let(:tempfile) { Tempfile.new(["test", ".html"]) }
    let(:path) { tempfile.path }

    after { tempfile.unlink rescue nil }

    it "removes the file" do
      expect(File.exist?(path)).to be true
      subject.destroy
      expect(File.exist?(path)).to be false
    end
  end

  describe "when file does not exist" do
    let(:path) { "/nonexistent/path/file.html" }

    describe "#data" do
      it "returns empty data object" do
        expect(subject.data.to_h).to eq({})
      end
    end

    describe "#body" do
      it "returns nil" do
        expect(subject.body).to be_nil
      end
    end

    describe "#exists?" do
      it "returns false" do
        expect(subject.exists?).to be false
      end
    end
  end

  describe "parse errors" do
    let(:tempfile) do
      file = Tempfile.new(["bad", ".html"])
      file.write("---\ninvalid: yaml: content: here\n---\nbody")
      file.close
      file
    end
    let(:path) { tempfile.path }

    after { tempfile.unlink rescue nil }

    it "raises ParseError with file path on invalid frontmatter" do
      expect { subject.data }.to raise_error(Sitepress::ParseError, /#{Regexp.escape(path)}/)
    end
  end

  describe ".mime_types" do
    it "returns array of supported MIME types" do
      expect(described_class.mime_types).to be_an(Array)
      expect(described_class.mime_types).to include("text/html")
    end
  end

  describe "#renderer" do
    it "returns a renderer instance" do
      expect(subject.renderer).to respond_to(:render)
    end
  end

  describe "#body=" do
    it "allows setting body directly" do
      subject.body = "new body content"
      expect(subject.body).to eq("new body content")
    end
  end

  describe "#data=" do
    it "allows setting data directly" do
      subject.data = { "key" => "value" }
      expect(subject.data["key"]).to eq("value")
    end

    it "wraps data in Data::Record object" do
      subject.data = { "key" => "value" }
      expect(subject.data).to be_a(Sitepress::Data::Record)
    end
  end
end
