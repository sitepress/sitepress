require "spec_helper"

describe "Mascot routes", type: :routing do
  context "routes enabled" do
    before do
      Mascot.configuration.routes = true
      Rails.application.reload_routes!
    end
    it "generates link" do
      expect(page_path("hi")).to eql("/hi")
    end
    it "is routable" do
      expect(get("/hi")).to route_to(controller: "mascot/sitemap", action: "show", path: "hi")
    end
  end
  context "routes disabled" do
    before do
      Mascot.configuration.routes = false
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
