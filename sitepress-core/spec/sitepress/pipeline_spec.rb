require "spec_helper"

describe Sitepress::ResourcesPipeline do
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/tree") }
  subject{ site.resources_pipeline }

  describe "#process" do
    it "calls #process on processor" do
      processor = double("Object", process_resources: [])
      expect(processor).to receive(:process_resources)
      subject << processor
      site.root
    end
  end
end
