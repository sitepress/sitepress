require "spec_helper"

describe Sitepress::Project do
  subject { Sitepress::Project.new config_file: "spec/sites/sample/site.rb" }

  context "#compiler" do
    it "is a Compiler" do
      expect(subject.compiler).to be_instance_of(Sitepress::Compiler)
    end
  end
  context "#server" do
    it "is a Server" do
      expect(subject.server).to be_instance_of(Sitepress::Server)
    end
  end
  context "#preview_server" do
    it "is a PreviewServer" do
      expect(subject.preview_server).to be_instance_of(Sitepress::PreviewServer)
    end
  end
  context "#site" do
    it "has a root path" do
      expect(subject.site.root_path.to_s).to eql("spec/sites/sample")
    end
  end
end
