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

  describe "#save" do
    subject { model.first }
    it "saves" do
      subject.save
    end
  end

  describe "#data" do
    subject { model.first }
    it "defines #title method" do
      expect(subject.title).to eql "Tick tock, tick tock"
    end
  end

  describe ".get" do
    subject { model.first }
    context "no page" do
      it "returns nil" do
        expect(model.get("does-not-exist")).to be_nil
      end
    end
    context "existing page" do
      it "returns page" do
        expect(model.get("hi")).to be_a(PageModel)
      end
    end
  end
end
