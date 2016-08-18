require "spec_helper"

describe Mascot::Extensions::IndexRequestPath do
  subject { Mascot::Extensions::IndexRequestPath.new }
  let(:site) { Mascot::Site.new(root: "spec/pages") }
  let(:resources) { site.resources }

  context "#process_resources" do
    before { subject.process_resources(resources) }
    it "changes /index.html request_path to /" do
      # require "pry" ; binding.pry
      expect(resources.get_resource("/").request_path).to eql("/")
    end
  end
end
