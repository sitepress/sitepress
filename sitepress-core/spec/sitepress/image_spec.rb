require "spec_helper"
require "tempfile"

RSpec.describe Sitepress::Image do
  describe "with a PNG file" do
    let(:png_data) do
      # Minimal valid 2x3 PNG (red pixel)
      [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, # PNG signature
        0x00, 0x00, 0x00, 0x0D, # IHDR length
        0x49, 0x48, 0x44, 0x52, # IHDR
        0x00, 0x00, 0x00, 0x02, # width = 2
        0x00, 0x00, 0x00, 0x03, # height = 3
        0x08, 0x02, # bit depth, color type
        0x00, 0x00, 0x00, # compression, filter, interlace
        0x90, 0x77, 0x53, 0xDE, # CRC
        0x00, 0x00, 0x00, 0x00, # IEND length
        0x49, 0x45, 0x4E, 0x44, # IEND
        0xAE, 0x42, 0x60, 0x82  # CRC
      ].pack("C*")
    end

    let(:tempfile) do
      Tempfile.new(["test", ".png"]).tap do |f|
        f.binmode
        f.write(png_data)
        f.rewind
      end
    end

    subject { described_class.new(path: tempfile.path) }

    after { tempfile.close! }

    describe "#format" do
      it "returns the file extension as symbol" do
        expect(subject.format).to eq(:png)
      end
    end

    describe "#mime_type" do
      it "returns the MIME type" do
        expect(subject.mime_type.to_s).to eq("image/png")
      end
    end

    describe "#exists?" do
      it "returns true when file exists" do
        expect(subject.exists?).to be true
      end

      it "returns false when file doesn't exist" do
        asset = described_class.new(path: "/nonexistent/image.png")
        expect(asset.exists?).to be false
      end
    end

    describe "#filename" do
      it "returns the basename" do
        expect(subject.filename).to include(".png")
      end
    end

    describe "#size" do
      it "returns the file size" do
        expect(subject.size).to eq(png_data.bytesize)
      end
    end

    describe "#width" do
      it "returns the image width" do
        expect(subject.width).to eq(2)
      end
    end

    describe "#height" do
      it "returns the image height" do
        expect(subject.height).to eq(3)
      end
    end

    describe "#body" do
      it "returns the raw binary content" do
        expect(subject.body).to eq(png_data)
      end
    end
  end

  describe "with a JPEG file" do
    let(:tempfile) do
      Tempfile.new(["test", ".jpg"]).tap do |f|
        f.binmode
        # Just write SOI marker for format detection
        f.write("\xFF\xD8\xFF\xD9")
        f.rewind
      end
    end

    subject { described_class.new(path: tempfile.path) }

    after { tempfile.close! }

    describe "#format" do
      it "returns :jpg" do
        expect(subject.format).to eq(:jpg)
      end
    end

    describe "#mime_type" do
      it "returns image/jpeg" do
        expect(subject.mime_type.to_s).to eq("image/jpeg")
      end
    end
  end

  describe "with a GIF file" do
    let(:gif_data) do
      # Minimal valid 5x6 GIF
      [
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, # GIF89a
        0x05, 0x00, # width = 5
        0x06, 0x00, # height = 6
        0x00, 0x00, 0x00, # flags, bgcolor, aspect
        0x3B # trailer
      ].pack("C*")
    end

    let(:tempfile) do
      Tempfile.new(["test", ".gif"]).tap do |f|
        f.binmode
        f.write(gif_data)
        f.rewind
      end
    end

    subject { described_class.new(path: tempfile.path) }

    after { tempfile.close! }

    describe "#width" do
      it "returns the image width" do
        expect(subject.width).to eq(5)
      end
    end

    describe "#height" do
      it "returns the image height" do
        expect(subject.height).to eq(6)
      end
    end
  end

  describe "as a Resource source" do
    let(:png_data) do
      [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x10, # width = 16
        0x00, 0x00, 0x00, 0x20, # height = 32
        0x08, 0x02, 0x00, 0x00, 0x00,
        0x90, 0x77, 0x53, 0xDE,
        0x00, 0x00, 0x00, 0x00,
        0x49, 0x45, 0x4E, 0x44,
        0xAE, 0x42, 0x60, 0x82
      ].pack("C*")
    end

    let(:tempfile) do
      Tempfile.new(["photo", ".png"]).tap do |f|
        f.binmode
        f.write(png_data)
        f.rewind
      end
    end

    let(:image_asset) { described_class.new(path: tempfile.path) }
    let(:node) { Sitepress::Node.new }
    let(:resource) { Sitepress::Resource.new(source: image_asset, node: node.child("photo"), format: :png) }

    after { tempfile.close! }

    it "has_data? returns true" do
      expect(resource.has_data?).to be true
    end

    it "data includes dimensions" do
      expect(resource.data["width"]).to eq(16)
      expect(resource.data["height"]).to eq(32)
    end

    it "renderable? returns false" do
      expect(resource.renderable?).to be false
    end

    it "source has dimensions" do
      expect(resource.source.width).to eq(16)
      expect(resource.source.height).to eq(32)
    end
  end
end
