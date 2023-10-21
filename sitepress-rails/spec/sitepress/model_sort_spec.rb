require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Model do
  let(:model) { SortModel }

  describe "#all" do
    subject { model.all.to_a }

    it "sorts collection alphabecitally by given symbol" do
      expect(subject.count).to(eql(2))

      expect(subject.first.title).to(eql("A Title"))
      expect(subject.second.title).to(eql("Z Title"))

      expect(subject.second).to(eql(subject.last))
    end
  end
end
