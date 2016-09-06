require "spec_helper"
require "mascot/extensions/proc_manipulator"

describe Mascot::Extensions::ProcManipulator do
  let(:site) { Mascot::Site.new(root_path: "spec/pages") }
  let(:root) { site.root }
  subject { Mascot::Extensions::ProcManipulator.new block }
  describe "#arity 1 procs" do
    let(:block) { Proc.new { |resource| } }
    it "is called with (resource)" do
      root.flatten.each do |resource|
        expect(block).to receive(:call).with(resource)
      end
      subject.process_resources(root)
    end
  end
  describe "arity 2 procs" do
    let(:block) { Proc.new { |resource, resources| } }
    it "is called with (resource, resources) for arity 2 procs" do
      root.flatten.each do |resource|
        expect(block).to receive(:call).with(resource, root)
      end
      subject.process_resources(root)
    end
  end
end
