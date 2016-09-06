require "spec_helper"

describe Mascot::Extensions::IndexRequestPath do
  subject { Mascot::Extensions::IndexRequestPath.new }
  let(:site) { Mascot::Site.new(root_path: "spec/pages") }
  let(:root) { site.root }

  context "#process_resources" do
    before { subject.process_resources(root) }
    it "changes /index.html request_path to /" do
      # require "pry" ; binding.pry
      expect(root.get("/").request_path).to eql("/")
    end
  end
end
