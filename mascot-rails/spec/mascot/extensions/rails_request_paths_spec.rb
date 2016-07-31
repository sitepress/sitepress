require "spec_helper"

describe Mascot::Extensions::RailsRequestPaths do
  context ".format_path" do
    it "converts /foo.bar/buzz.html to /foo.bar/buzz" do
      expect(Mascot::Extensions::RailsRequestPaths.format_path("/foo.bar/buzz"))
    end
  end
end
