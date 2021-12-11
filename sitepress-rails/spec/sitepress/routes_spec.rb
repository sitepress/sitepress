require "spec_helper"

describe "Sitepress routes", type: :routing do
  before do
    Rails.application.reload_routes!
  end
  it "generates link" do
    expect(page_path("hi")).to eql("/hi")
  end
  it "is routable" do
    expect(get("/hi")).to route_to(controller: "sitepress/site", action: "show", resource_path: "hi")
  end
end
