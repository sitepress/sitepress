require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Compiler do
  let(:root_path) { File.expand_path("spec/sites/sample") }
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/sample") }
  let(:target) { Pathname.new(Dir::tmpdir).join("build") }
  subject { Sitepress::Compiler.new(site: site) }

  describe "#compile" do
    include
    before do
      FileUtils.mkdir_p(target)
      subject.compile(target_path: target)
    end
    after do
      FileUtils.rm_rf(target)
    end
    it "writes files to target" do
      expect(Dir.glob(target.join("**")).size).to eql(5) # 5 items in the site... mkay?
    end
  end
end
