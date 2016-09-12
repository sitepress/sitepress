require "spec_helper"

describe Sitepress::Extensions::RailsRequestPaths do
  context ".format_path" do
    it "converts /foo.bar/buzz.html to /foo.bar/buzz" do
      expect(Sitepress::Extensions::RailsRequestPaths.format_path("/foo.bar/buzz"))
    end
  end
end
