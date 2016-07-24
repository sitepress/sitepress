require "spec_helper"

describe Mascot::ActionControllerContext do
  subject { Mascot::ActionControllerContext.new(controller: controller, sitemap: sitemap) }
  let(:sitemap) { Mascot.configuration.sitemap }
  let(:resource) { sitemap.resources("**.erb*").first }
  context "#render" do
    let(:controller) { instance_double("Controller", render: true, _layout: "application") }
    it "calls render" do
      expect(controller).to receive(:render).with(inline: resource.body,
        type: "erb",
        layout: "flipper",
        locals: {
          sitemap: sitemap,
          current_page: resource,
          cat: "in-a-hat"
        },
        content_type: resource.mime_type.to_s)
      subject.render(resource.request_path, locals: {cat: "in-a-hat"}, layout: "flipper")
    end
  end
end
