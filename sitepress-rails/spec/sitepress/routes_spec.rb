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

  describe "sitepress_pages with root: true" do
    before do
      Rails.application.routes.draw do
        sitepress_pages root: true
      end
    end

    it "creates root route" do
      expect(get("/")).to route_to(controller: "sitepress/site", action: "show")
    end
  end

  describe "sitepress_pages with custom route name" do
    before do
      Rails.application.routes.draw do
        sitepress_pages as: :custom_page
      end
    end

    it "routes to default controller" do
      expect(get("/hi")).to route_to(controller: "sitepress/site", action: "show", resource_path: "hi")
    end

    it "generates custom named path" do
      expect(custom_page_path("hi")).to eql("/hi")
    end
  end

  describe "sitepress_root when root already defined" do
    it "warns about existing root route" do
      expect(Rails.logger).to receive(:warn).with(/already defined/)
      Rails.application.routes.draw do
        root to: "other#index"
        sitepress_root
      end
    end
  end
end
