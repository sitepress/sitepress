require "spec_helper"

describe Mascot::RailsConfiguration do
  subject { Mascot::RailsConfiguration.new }
  context "#partials" do
    it "excludes partials" do
      expect(subject.site.resources.size).to eql(2)
    end
  end
end
