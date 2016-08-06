require "spec_helper"

describe Mascot::ResourcesPipeline do
  let(:sitemap) { Mascot::Sitemap.new(root: "spec/pages") }
  subject{ sitemap.resources_pipeline }

  describe "#process" do
    it "calls #process on processor" do
      processor = double("Object", process_resources: [])
      expect(processor).to receive(:process_resources)
      subject << processor
      sitemap.resources
    end
  end
end
