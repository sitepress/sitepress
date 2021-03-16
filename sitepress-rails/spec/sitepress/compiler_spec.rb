require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Compiler do
  let(:site) { Sitepress.site }
  let(:build_path) { Pathname.new(Dir::tmpdir).join("build") }
  # Write compiler output to /dev/null so our test output remains clean.
  let(:stdout) { File.open(File::NULL, "w")  }
  subject { Sitepress::Compiler.new(site: site, stdout: stdout, root_path: build_path) }
  describe "#compile" do
    before { FileUtils.mkdir_p(build_path) }
    after { FileUtils.rm_rf(build_path) }
    it "writes files to build_path" do
      subject.compile
      expect(Dir.glob(build_path.join("**")).size).to eql(2) # 2 items in the site... mkay?
    end
  end
end
