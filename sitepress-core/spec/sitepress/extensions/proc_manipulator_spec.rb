require "spec_helper"
require "sitepress/extensions/proc_manipulator"

describe Sitepress::Extensions::ProcManipulator do
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/tree") }
  let(:root) { site.root }
  subject { Sitepress::Extensions::ProcManipulator.new block }
  let(:block) { Proc.new { |root| } }
  it "passes root node into proc" do
    expect(block).to receive(:call).with(root)
    subject.process_resources(root)
  end
end
