require "spec_helper"

describe "Sitepress routes", type: :routing do
  context "routes enabled" do
    before do
      Sitepress.configuration.routes = true
      Rails.application.reload_routes!
    end
    it "generates link" do
      expect(page_path("hi")).to eql("/hi")
    end
    it "is routable" do
      expect(get("/hi")).to route_to(controller: "sitepress/site", action: "show", resource_path: "hi")
    end
  end
  context "routes disabled" do
    before do
      Sitepress.configuration.routes = false
      Rails.application.reload_routes!
    end
    it "is not routable" do
      expect(get("/hi")).to_not be_routable
    end
    it "does not generate link" do
      expect{page_path("hi")}.to raise_exception(NoMethodError)
    end
  end
end
