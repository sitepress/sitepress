require "spec_helper"

RSpec.describe Sitepress::Server do
  let(:app) { ->(env) { [200, { "Content-Type" => "text/plain" }, ["Hello"]] } }
  subject { described_class.new(app) }

  describe "#initialize" do
    it "sets app" do
      expect(subject.app).to eq(app)
    end

    it "sets default host" do
      expect(subject.host).to eq(Sitepress::Server::DEFAULT_HOST)
    end

    it "sets default port" do
      expect(subject.port).to eq(Sitepress::Server::DEFAULT_PORT)
    end

    it "has no reloader by default" do
      expect(subject.reloader).to be_nil
    end

    it "starts with empty processes" do
      expect(subject.processes).to be_empty
    end

    context "with reloader" do
      let(:reloader) { Sitepress::Reloader.new }
      subject { described_class.new(app, reloader: reloader) }

      it "sets reloader" do
        expect(subject.reloader).to eq(reloader)
      end
    end
  end

  describe "#add_process" do
    it "adds a process" do
      subject.add_process(:css, "echo test")
      expect(subject.processes.size).to eq(1)
    end

    it "returns the created process" do
      process = subject.add_process(:css, "echo test")
      expect(process).to be_a(Sitepress::Process)
    end

    it "sets the process label" do
      process = subject.add_process(:css, "echo test")
      expect(process.label).to eq(:css)
    end

    it "sets the process command" do
      process = subject.add_process(:css, "echo test")
      expect(process.command).to eq("echo test")
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

  describe "constants" do
    it "has default host" do
      expect(Sitepress::Server::DEFAULT_HOST).to eq("127.0.0.1")
    end

    it "has default port" do
      expect(Sitepress::Server::DEFAULT_PORT).to eq(8080)
    end
  end
end
