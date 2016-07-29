require "spec_helper"

describe Mascot::RailsConfiguration do
  subject { Mascot.configuration }
  let(:sitemap) { Mascot.configuration.sitemap }
  context "resouces" do
    it "excludes partials" do
      expect(subject.resources.size).to eql(sitemap.resources.size - 1)
    end
  end
end
