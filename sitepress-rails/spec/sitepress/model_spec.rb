require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Model do
  let(:model) { PageModel }

  describe "#all" do
    subject { model.all }
    context "models" do
      it "has correct count" do
        expect(subject.count).to eql 3
      end
      it "is instances of model" do
        expect(subject.first).to be_instance_of PageModel
      end
    end
    describe "#resources" do
      subject { model.all.resources }
      it "has correct count" do
        expect(subject.count).to eql 3
      end
      it "is instances of pages" do
        expect(subject.first).to be_instance_of Sitepress::Resource
      end
    end
  end

  describe ".data" do
    subject { model.first }
    it "defines #title method" do
      expect(subject).to respond_to :title
    end
  end
end
