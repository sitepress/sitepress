require "spec_helper"
require "tmpdir"
require "fileutils"
require "net/http"
require "timeout"
require "socket"

RSpec.describe "CLI Integration", :integration do
  let(:tmpdir) { Dir.mktmpdir }
  let(:project_path) { File.join(tmpdir, "test_site") }
  let(:sitepress_root) { File.expand_path("../../../..", __FILE__) }

  # Find an available port for testing
  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    server.close
    port
  end

  after do
    FileUtils.rm_rf(tmpdir)
  end

  # Run sitepress from a generated project directory (has its own Gemfile)
  def run_sitepress(*args, dir: project_path, timeout: 60)
    Bundler.with_unbundled_env do
      Dir.chdir(dir) do
        Timeout.timeout(timeout) do
          `bundle exec sitepress #{args.join(" ")} 2>&1`
        end
      end
    end
  end

  # Run sitepress from the sitepress repo (for commands like new, version)
  def run_sitepress_from_repo(*args, timeout: 30)
    Dir.chdir(sitepress_root) do
      Timeout.timeout(timeout) do
        `bundle exec sitepress #{args.join(" ")} 2>&1`
      end
    end
  end

  def run_sitepress_bg(*args, dir: project_path)
    log_file = File.join(tmpdir, "server.log")
    Bundler.with_unbundled_env do
      Dir.chdir(dir) do
        spawn("bundle exec sitepress #{args.join(" ")} > #{log_file} 2>&1")
      end
    end
  end

  # Rewrite Gemfile to use local sitepress path for faster bundle install
  def use_local_sitepress!
    gemfile = File.join(project_path, "Gemfile")
    content = File.read(gemfile)
    content.gsub!(/gem ["']sitepress["'].*$/, %Q{gem "sitepress", path: "#{sitepress_root}"})
    File.write(gemfile, content)
  end

  def create_project_with_local_sitepress!
    run_sitepress_from_repo("new", project_path)
    use_local_sitepress!
    Bundler.with_unbundled_env do
      Dir.chdir(project_path) do
        system("bundle install --quiet")
      end
    end
  end

  describe "sitepress new" do
    it "creates a new project with expected files" do
      output = run_sitepress_from_repo("new", project_path)
      expect($?.success?).to be(true), "sitepress new failed: #{output}"

      expect(File.exist?(File.join(project_path, "Gemfile"))).to be true
      expect(File.exist?(File.join(project_path, "config", "site.rb"))).to be true
      expect(Dir.exist?(File.join(project_path, "pages"))).to be true
    end
  end

  describe "sitepress server", :slow do
    before { create_project_with_local_sitepress! }

    it "starts and responds to HTTP requests" do
      port = find_available_port
      pid = run_sitepress_bg("server", "-p", port.to_s)
      log_file = File.join(tmpdir, "server.log")

      begin
        # Wait for server to start with retries
        uri = URI("http://127.0.0.1:#{port}/")
        response = nil

        10.times do |i|
          sleep 1
          begin
            response = Net::HTTP.get_response(uri)
            break if response.code.to_i < 500
          rescue Errno::ECONNREFUSED
            # Server not ready yet, keep trying
          end
        end

        if response.nil? || response.code.to_i >= 500
          puts "\n=== Server log ===\n#{File.read(log_file) rescue 'Could not read log'}\n=== End log ==="
        end

        expect(response).not_to be_nil
        expect(response.code.to_i).to be_between(200, 399)
      ensure
        Process.kill("TERM", pid) rescue nil
        Process.wait(pid) rescue nil
      end
    end
  end

  describe "sitepress console", :slow do
    before { create_project_with_local_sitepress! }

    it "starts and can evaluate expressions" do
      output = nil
      Bundler.with_unbundled_env do
        Dir.chdir(project_path) do
          IO.popen("bundle exec sitepress console 2>&1", "r+") do |io|
            io.puts "1 + 1"
            io.puts "exit"
            io.close_write
            output = io.read
          end
        end
      end

      expect(output).to include("2")
    end
  end

  describe "sitepress compile", :slow do
    before { create_project_with_local_sitepress! }

    it "compiles the site to build directory" do
      output = run_sitepress("compile")

      expect($?.success?).to be(true), "sitepress compile failed: #{output}"
      expect(Dir.exist?(File.join(project_path, "build"))).to be true
    end
  end

  describe "sitepress version" do
    it "outputs the version number" do
      output = run_sitepress_from_repo("version")
      expect(output).to match(/\d+\.\d+\.\d+/)
    end
  end
end
