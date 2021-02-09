require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Compiler do
  let(:site) { Sitepress.site }
  let(:target) { Pathname.new(Dir::tmpdir).join("build") }
  # Write compiler output to /dev/null so our test output remains clean.
  let(:stdout) { File.open(File::NULL, "w")  }
  subject { Sitepress::Compiler.new(site: site, stdout: stdout) }
  describe "#compile" do
    before { FileUtils.mkdir_p(target) }
    after { FileUtils.rm_rf(target) }
    it "writes files to target" do
      subject.compile(target_path: target)
      expect(Dir.glob(target.join("**")).size).to eql(2) # 2 items in the site... mkay?
    end
  end
end
