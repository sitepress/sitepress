require "spec_helper"

RSpec.describe Sitepress::Plugins do
  before do
    described_class.reset!
  end

  describe ".register" do
    let(:cli_class) { Class.new(Thor) }

    it "adds plugin to registry" do
      described_class.register(name: "test", cli: cli_class)
      expect(described_class.registered).to include("test")
    end

    it "stores cli class" do
      described_class.register(name: "test", cli: cli_class)
      expect(described_class.get("test")[:cli]).to eq(cli_class)
    end

    it "stores description" do
      described_class.register(name: "test", cli: cli_class, description: "Test plugin")
      expect(described_class.get("test")[:description]).to eq("Test plugin")
    end

    it "uses default description when not provided" do
      described_class.register(name: "test", cli: cli_class)
      expect(described_class.get("test")[:description]).to eq("test commands")
    end

    it "converts name to string" do
      described_class.register(name: :test, cli: cli_class)
      expect(described_class.registered).to include("test")
    end

    it "warns on duplicate registration" do
      described_class.register(name: "test", cli: cli_class)
      expect {
        described_class.register(name: "test", cli: cli_class)
      }.to output(/already registered/).to_stderr
    end

    it "does not overwrite existing plugin" do
      original_class = Class.new(Thor)
      new_class = Class.new(Thor)

      described_class.register(name: "test", cli: original_class)
      described_class.register(name: "test", cli: new_class)

      expect(described_class.get("test")[:cli]).to eq(original_class)
    end
  end

  describe ".registered" do
    it "returns empty array when no plugins" do
      expect(described_class.registered).to eq([])
    end

    it "returns list of registered plugin names" do
      described_class.register(name: "foo", cli: Class.new(Thor))
      described_class.register(name: "bar", cli: Class.new(Thor))
      expect(described_class.registered).to contain_exactly("foo", "bar")
    end
  end

  describe ".get" do
    it "returns nil for unknown plugin" do
      expect(described_class.get("unknown")).to be_nil
    end

    it "returns plugin hash for known plugin" do
      cli_class = Class.new(Thor)
      described_class.register(name: "test", cli: cli_class)
      expect(described_class.get("test")).to be_a(Hash)
    end
  end

  describe ".each" do
    it "iterates over all plugins" do
      described_class.register(name: "foo", cli: Class.new(Thor))
      described_class.register(name: "bar", cli: Class.new(Thor))

      names = []
      described_class.each { |name, _| names << name }
      expect(names).to contain_exactly("foo", "bar")
    end
  end

  describe ".reset!" do
    it "clears the registry" do
      described_class.register(name: "test", cli: Class.new(Thor))
      described_class.reset!
      expect(described_class.registered).to eq([])
    end
  end

  describe ".discover!" do
    context "without Bundler" do
      before do
        hide_const("Bundler")
      end

      it "does nothing without Bundler" do
        expect { described_class.discover! }.not_to raise_error
      end
    end
  end
end
