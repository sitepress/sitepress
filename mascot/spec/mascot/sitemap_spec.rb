require "spec_helper"

context Mascot::Sitemap do
  subject { Mascot::Sitemap.new(file_path: "spec/pages") }
  let(:resource_count) { 4 }
  it "has 3 resources" do
    expect(subject.resources.size).to eql(resource_count)
  end
  context "#glob" do
    it "globs resources" do
      expect(subject.resources("*sin_frontmatter*").size).to eql(1)
    end
    it "raises exception for glob outside of sitemap file_path" do
      expect{subject.resources("./..")}.to raise_exception(Mascot::InsecurePathAccessError)
    end
  end
  describe "#find_by_request_path" do
    it "finds with leading /" do
      expect(subject.find_by_request_path("/test")).to_not be_nil
    end
    it "finds without leading /" do
      expect(subject.find_by_request_path("test")).to_not be_nil
    end
    it "finds nil" do
      expect(subject.find_by_request_path(nil)).to be_nil
    end
    it "does not traverse directories" do
      expect(subject.find_by_request_path("/../pages/test")).to be_nil
    end
  end
end
