require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Sitepress::CLI do
  describe "constants" do
    it "has default server port" do
      expect(described_class::SERVER_PORT).to eq(8080)
    end

    it "has default bind address" do
      expect(described_class::SERVER_BIND_ADDRESS).to eq("127.0.0.1")
    end

    it "has default compile target path" do
      expect(described_class::COMPILE_TARGET_PATH).to eq("./build")
    end

    it "has site error reporting enabled by default" do
      expect(described_class::SERVER_SITE_ERROR_REPORTING).to be true
    end

    it "has site reloading enabled by default" do
      expect(described_class::SERVER_SITE_RELOADING).to be true
    end
  end

  describe "class" do
    it "inherits from Thor" do
      expect(described_class.superclass).to eq(Thor)
    end

    it "includes Thor::Actions" do
      expect(described_class.included_modules).to include(Thor::Actions)
    end
  end

  describe "commands" do
    it "has server command" do
      expect(described_class.commands).to have_key("server")
    end

    it "has compile command" do
      expect(described_class.commands).to have_key("compile")
    end

    it "has console command" do
      expect(described_class.commands).to have_key("console")
    end

    it "has new command" do
      expect(described_class.commands).to have_key("new")
    end

    it "has version command" do
      expect(described_class.commands).to have_key("version")
    end
  end

  describe "#version" do
    it "outputs the version" do
      expect { described_class.start(%w[version]) }.to output(/\d+\.\d+\.\d+/).to_stdout
    end
  end

  describe "#new" do
    let(:tmpdir) { Dir.mktmpdir }
    let(:target) { File.join(tmpdir, "new_site") }

    after do
      FileUtils.rm_rf(tmpdir)
    end

    it "creates a new project directory", skip: "requires bundle install" do
      # This test is skipped because it runs bundle install
      # which is slow and requires network access
      described_class.start(%W[new #{target}])
      expect(Dir.exist?(target)).to be true
    end
  end

  describe "server command options" do
    let(:command) { described_class.commands["server"] }

    it "has bind_address option" do
      expect(command.options).to have_key(:bind_address)
    end

    it "has port option" do
      expect(command.options).to have_key(:port)
    end

    it "has site_reloading option" do
      expect(command.options).to have_key(:site_reloading)
    end

    it "has site_error_reporting option" do
      expect(command.options).to have_key(:site_error_reporting)
    end

    it "port option has correct default" do
      expect(command.options[:port].default).to eq(8080)
    end

    it "bind_address option has correct default" do
      expect(command.options[:bind_address].default).to eq("127.0.0.1")
    end
  end

  describe "compile command options" do
    let(:command) { described_class.commands["compile"] }

    it "has output_path option" do
      expect(command.options).to have_key(:output_path)
    end

    it "has fail_on_error option" do
      expect(command.options).to have_key(:fail_on_error)
    end

    it "output_path option has correct default" do
      expect(command.options[:output_path].default).to eq("./build")
    end

    it "fail_on_error option defaults to false" do
      expect(command.options[:fail_on_error].default).to be false
    end
  end

  describe "command descriptions" do
    it "server has description" do
      expect(described_class.commands["server"].description).to eq("Run preview server")
    end

    it "compile has description" do
      expect(described_class.commands["compile"].description).to eq("Compile project into static pages")
    end

    it "console has description" do
      expect(described_class.commands["console"].description).to eq("Interactive project shell")
    end

    it "new has description" do
      expect(described_class.commands["new"].description).to eq("Create new project at PATH")
    end

    it "version has description" do
      expect(described_class.commands["version"].description).to eq("Show version")
    end
  end
end
