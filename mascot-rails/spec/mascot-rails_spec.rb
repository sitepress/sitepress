require "spec_helper"
require "rails"
require "mascot-rails"

describe Mascot::RouteConstraint do
  let(:sitemap) { Mascot::Sitemap.new(file_path: "spec/pages") }
  let(:route_constraint) { Mascot::RouteConstraint.new(sitemap) }

  context "#matches?" do
    it "returns true if match" do
      request = double("request", path: "/test")
      expect(route_constraint.matches?(request)).to be(true)
    end
    it "returns false if not match" do
      request = double("request", path: "/does-not-exist")
      expect(route_constraint.matches?(request)).to be(false)
    end
  end
end

describe Mascot::SitemapController, type: :controller do
  context "existing templated page" do
    render_views
    before { get :show, path: "/time" }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Tick tock, tick tock</h1>")
    end
    it "renders layout" do
      expect(response.body).to include("<title>Dummy</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to eql("text/html")
    end
  end

  context "existing static page" do
    render_views
    before { get :show, path: "/hi" }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Hi!</h1>")
    end
    it "renders layout" do
      expect(response.body).to include("<title>Dummy</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to eql("text/html")
    end
  end

  context "non-existent page" do
    it "is status 404" do
      expect {
        get :show, path: "/non-existent"
      }.to raise_exception(ActionController::RoutingError)
    end
  end
end
