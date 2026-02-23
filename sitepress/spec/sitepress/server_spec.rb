require "spec_helper"

RSpec.describe Sitepress::ApplicationServer do
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  subject { described_class.new(site) }

  describe "#initialize" do
    it "sets site" do
      expect(subject.site).to eq(site)
    end

    it "sets default host" do
      expect(subject.host).to eq(Sitepress::Server::DEFAULT_HOST)
    end

    it "sets default port" do
      expect(subject.port).to eq(Sitepress::Server::DEFAULT_PORT)
    end

    it "disables live_reload by default" do
      expect(subject.live_reload).to be false
    end

    it "starts with empty processes" do
      expect(subject.processes).to be_empty
    end
  end

  describe "#add_process" do
    it "adds a process config" do
      subject.add_process(:css, "tailwindcss -w")
      expect(subject.processes.size).to eq(1)
    end

    it "stores label and command as array" do
      subject.add_process(:css, "tailwindcss -w")
      expect(subject.processes.first).to eq([:css, "tailwindcss -w"])
    end
  end

  describe "#live_reload=" do
    it "enables live reload" do
      subject.live_reload = true
      expect(subject.live_reload).to be true
    end
  end

  describe "#host=" do
    it "sets custom host" do
      subject.host = "0.0.0.0"
      expect(subject.host).to eq("0.0.0.0")
    end
  end

  describe "#port=" do
    it "sets custom port" do
      subject.port = 3000
      expect(subject.port).to eq(3000)
    end
  end
end
