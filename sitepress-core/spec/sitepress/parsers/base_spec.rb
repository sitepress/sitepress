require "spec_helper"

RSpec.describe Sitepress::Parsers::Base do
  let(:source) { "Hello, world!" }
  subject { described_class.new(source) }

  describe "#body" do
    it "returns the source unchanged" do
      expect(subject.body).to eq(source)
    end

    context "with multiline content" do
      let(:source) { "Line 1\nLine 2\nLine 3" }

      it "preserves all lines" do
        expect(subject.body).to eq(source)
      end
    end

    context "with empty source" do
      let(:source) { "" }

      it "returns empty string" do
        expect(subject.body).to eq("")
      end
    end
  end

  describe "#data" do
    it "returns empty hash" do
      expect(subject.data).to eq({})
    end

    context "with content that looks like YAML" do
      let(:source) { "---\ntitle: Test\n---\nbody" }

      it "still returns empty hash (no parsing)" do
        expect(subject.data).to eq({})
      end

      it "returns entire content as body" do
        expect(subject.body).to eq(source)
      end
    end
  end

  describe "#body_line_offset" do
    it "returns 1" do
      expect(subject.body_line_offset).to eq(1)
    end
  end
end
