require "spec_helper"

describe Mascot::RailsConfiguration do
  subject { Mascot::RailsConfiguration.new }
  context "#partials" do
    it "excludes by default" do
      expect(subject.partials).to be false
    end
    it "excludes partials if false" do
      subject.partials = false
      expect(subject.resources.to_a.size).to eql(2)
    end
    it "includes partials if true" do
      subject.partials = true
      expect(subject.resources.to_a.size).to eql(3)
    end
  end
end
