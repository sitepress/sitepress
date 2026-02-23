require "spec_helper"

RSpec.describe Sitepress::Process do
  subject { described_class.new(label: :css, command: "echo hello") }

  describe "#initialize" do
    it "sets label" do
      expect(subject.label).to eq(:css)
    end

    it "sets command" do
      expect(subject.command).to eq("echo hello")
    end

    it "converts label to symbol" do
      process = described_class.new(label: "js", command: "node build.js")
      expect(process.label).to eq(:js)
    end
  end

  describe "#color" do
    it "is nil by default" do
      expect(subject.color).to be_nil
    end

    it "can be set" do
      subject.color = :red
      expect(subject.color).to eq(:red)
    end
  end

  describe "#run" do
    it "yields each line of output" do
      lines = []
      subject.run { |line| lines << line }
      expect(lines).to eq(["hello"])
    end

    it "captures stderr" do
      process = described_class.new(label: :test, command: "echo error >&2")
      lines = []
      process.run { |line| lines << line }
      expect(lines).to eq(["error"])
    end
  end

  describe ".color_for_index" do
    it "returns a color for index 0" do
      expect(described_class.color_for_index(0)).to eq(:red)
    end

    it "cycles through colors" do
      colors = 10.times.map { |i| described_class.color_for_index(i) }
      expect(colors.uniq.size).to be <= described_class::COLORS.size
    end
  end

  describe "COLORS" do
    it "has multiple colors" do
      expect(described_class::COLORS.size).to be >= 4
    end
  end
end
