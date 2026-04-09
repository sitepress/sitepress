require "spec_helper"

describe Sitepress::Compilers do
  # A minimal stub that responds to the compiler-instance protocol the
  # collection actually exercises (#compile, plus the optional
  # #succeeded / #failed that callers might flat_map over).
  let(:stub_compiler_class) do
    Class.new do
      attr_reader :compiled, :succeeded, :failed
      def initialize
        @compiled = false
        @succeeded = []
        @failed = []
      end
      def compile
        @compiled = true
        self
      end
    end
  end

  let(:a) { stub_compiler_class.new }
  let(:b) { stub_compiler_class.new }

  describe "#initialize" do
    it "starts empty by default" do
      expect(described_class.new.to_a).to eq([])
    end

    it "accepts an array of compilers" do
      collection = described_class.new([a, b])
      expect(collection.to_a).to eq([a, b])
    end
  end

  describe "#<<" do
    it "adds a compiler and returns self for chaining" do
      collection = described_class.new
      expect(collection << a).to equal(collection)
      expect(collection.to_a).to eq([a])
    end

    it "chains" do
      collection = described_class.new
      (collection << a) << b
      expect(collection.to_a).to eq([a, b])
    end
  end

  describe "#concat" do
    it "merges an Array of compilers, adding each as a separate element" do
      collection = described_class.new([a])
      collection.concat([b])
      expect(collection.to_a).to eq([a, b])
    end

    it "returns self for chaining" do
      collection = described_class.new
      expect(collection.concat([a, b])).to equal(collection)
    end

    it "accepts another Compilers (Enumerable.to_a)" do
      collection = described_class.new
      other = described_class.new([a, b])
      collection.concat(other)
      expect(collection.to_a).to eq([a, b])
    end

    it "accepts a lazy enumerator" do
      collection = described_class.new
      collection.concat([a, b].each)
      expect(collection.to_a).to eq([a, b])
    end
  end

  describe "#compile" do
    it "calls #compile on every member" do
      described_class.new([a, b]).compile
      expect(a.compiled).to be true
      expect(b.compiled).to be true
    end

    it "returns self so callers can chain introspection" do
      collection = described_class.new([a])
      expect(collection.compile).to equal(collection)
    end

    it "runs members in insertion order" do
      order = []
      a.define_singleton_method(:compile) { order << :a }
      b.define_singleton_method(:compile) { order << :b }
      described_class.new([a, b]).compile
      expect(order).to eq([:a, :b])
    end
  end

  describe "Enumerable" do
    it "exposes #each yielding members" do
      collection = described_class.new([a, b])
      expect(collection.to_a).to eq([a, b])
    end

    it "supports flat_map for aggregation across members" do
      a.succeeded.concat([:r1, :r2])
      b.succeeded.concat([:r3])
      collection = described_class.new([a, b])
      expect(collection.flat_map(&:succeeded)).to eq([:r1, :r2, :r3])
    end
  end
end
