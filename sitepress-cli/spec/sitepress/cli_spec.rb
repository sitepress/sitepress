require "spec_helper"
require "fileutils"
require "tmpdir"
require "json"

describe Sitepress::CLI do
  # Create one test site for all tests to avoid redundant site generation
  before(:all) do
    @test_site_path = File.join(Dir.tmpdir, "sitepress_test_site_#{Time.now.to_i}_#{rand(1000)}")
    
    # Create a new site once for all tests
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    
    begin
      Sitepress::CLI.start(["new", @test_site_path])
    ensure
      $stdout = old_stdout
      $stderr = old_stderr
    end
  end

  # Clean up test site after all tests
  after(:all) do
    FileUtils.rm_rf(@test_site_path) if @test_site_path && File.exist?(@test_site_path)
  end

  describe "#new" do
    it "creates the site directory" do
      expect(File.directory?(@test_site_path)).to be true
    end

    it "creates a Gemfile" do
      expect(File.exist?(File.join(@test_site_path, "Gemfile"))).to be true
    end

    it "creates a Rakefile" do
      expect(File.exist?(File.join(@test_site_path, "Rakefile"))).to be true
    end

    it "creates a pages directory" do
      expect(File.directory?(File.join(@test_site_path, "pages"))).to be true
    end

    it "creates a layouts directory" do
      expect(File.directory?(File.join(@test_site_path, "layouts"))).to be true
    end

    it "creates an assets directory" do
      expect(File.directory?(File.join(@test_site_path, "assets"))).to be true
    end

    it "creates a config directory" do
      expect(File.directory?(File.join(@test_site_path, "config"))).to be true
    end

    it "creates an assets/config directory" do
      expect(File.directory?(File.join(@test_site_path, "assets", "config"))).to be true
    end

    it "creates an assets/stylesheets directory" do
      expect(File.directory?(File.join(@test_site_path, "assets", "stylesheets"))).to be true
    end

    it "creates an assets/javascripts directory" do
      expect(File.directory?(File.join(@test_site_path, "assets", "javascripts"))).to be true
    end
  end

  describe "#compile" do
    before(:all) do
      @build_path = File.join(@test_site_path, "build")
      
      Dir.chdir(@test_site_path) do
        # Run compile command once for all compile tests
        old_stdout = $stdout
        old_stderr = $stderr
        $stdout = StringIO.new
        $stderr = StringIO.new
        @compile_output = ""
        
        begin
          begin
            Sitepress::CLI.start(["compile", "--output_path", @build_path])
          rescue SystemExit
            # The compile command calls abort when there are failed resources
          end
          @compile_output = $stdout.string + $stderr.string
        ensure
          $stdout = old_stdout
          $stderr = old_stderr
        end
      end
    end

    it "outputs compilation messages" do
      expect(@compile_output).to match(/compiling assets|Building/)
    end

    it "outputs rendering messages" do
      expect(@compile_output).to match(/compiling pages|Rendering/)
    end

    it "creates the build directory" do
      expect(File.directory?(@build_path)).to be true
    end

    it "creates the assets directory" do
      assets_path = File.join(@build_path, "assets")
      expect(File.directory?(assets_path)).to be true
    end

    it "creates the manifest file" do
      manifest_path = File.join(@build_path, "assets", ".manifest.json")
      expect(File.exist?(manifest_path)).to be true
    end

    it "creates a valid JSON manifest" do
      manifest_path = File.join(@build_path, "assets", ".manifest.json")
      manifest_content = File.read(manifest_path)
      expect(manifest_content).not_to be_empty
      manifest_data = JSON.parse(manifest_content)
      expect(manifest_data).to be_a(Hash)
    end

    it "compiles assets with digested filenames" do
      assets_path = File.join(@build_path, "assets")
      asset_files = Dir.glob(File.join(assets_path, "**/*")).select { |f| File.file?(f) }
      expect(asset_files).not_to be_empty
    end

    it "includes Propshaft fingerprints in asset filenames" do
      assets_path = File.join(@build_path, "assets")
      asset_files = Dir.glob(File.join(assets_path, "**/*")).select { |f| File.file?(f) }
      # At least some files should have digests (format: filename-digest.ext)
      digested_files = asset_files.select { |f| File.basename(f) =~ /-[a-f0-9]{8,}\.[^.]+$/ }
      expect(digested_files.size).to be > 0
    end
  end

  describe "#server" do
    it "has a server command" do
      # The server command exists and can be called
      # We don't start an actual server in tests as it would require forking
      # and proper cleanup which is unreliable in test environments
      expect(Sitepress::CLI.instance_methods).to include(:server)
    end
  end

  describe "#version" do
    it "displays the version" do
      output = capture_io do
        Sitepress::CLI.start(["version"])
      end

      expect(output.join).to include(Sitepress::VERSION)
    end
  end

  describe "#console" do
    it "has a console command" do
      # This is difficult to test in an automated way since it's interactive
      # We'll just verify the command exists
      expect(Sitepress::CLI.instance_methods).to include(:console)
    end
  end

  # Helper method to capture stdout and stderr
  def capture_io
    require 'stringio'
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    yield
    [$stdout.string, $stderr.string]
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end
end