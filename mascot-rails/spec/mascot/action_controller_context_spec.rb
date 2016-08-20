require "spec_helper"

describe Mascot::ActionControllerContext do
  subject { Mascot::ActionControllerContext.new(controller: controller, root: root) }
  let(:root) { Mascot.configuration.root }
  let(:site) { Mascot.configuration.site }
  let(:resource) { site.glob("**.erb*").first }
  context "#render" do
    let(:controller) { instance_double("Controller", render: true, _layout: "application") }
    it "calls render" do
      expect(controller).to receive(:render).with(inline: resource.body,
        type: "erb",
        layout: "flipper",
        locals: {
          current_page: resource,
          cat: "in-a-hat",
          root: root
        },
        content_type: resource.mime_type.to_s)
      subject.render(resource, locals: {cat: "in-a-hat"}, layout: "flipper")
    end
  end
end
