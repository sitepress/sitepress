require "spec_helper"
require "rails"
require "mascot-rails"

describe Mascot do
  context "default configuration" do
    subject{ Mascot.configuration }
    it "has sitemap" do
      expect(subject.sitemap.file_path).to eql(Rails.root.join("app/pages"))
    end
    it "has Rails.application as parent engine" do
      expect(subject.parent_engine).to eql(Rails.application)
    end
    it "has routes enabled by default" do
      expect(subject.routes).to be true
    end
  end
end

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

describe Mascot::ActionControllerContext do
  subject { Mascot::ActionControllerContext.new(controller: controller, sitemap: sitemap) }
  let(:sitemap) { Mascot.configuration.sitemap }
  let(:resource) { sitemap.resources("**.erb*").first }
  context "#render" do
    let(:controller) { instance_double("Controller", render: true, _layout: "application") }
    it "calls render" do
      expect(controller).to receive(:render).with(inline: resource.body,
        type: "erb",
        layout: "flipper",
        locals: {
          sitemap: sitemap,
          current_page: resource,
          cat: "in-a-hat"
        },
        content_type: resource.mime_type.to_s)
      subject.render(resource.request_path, locals: {cat: "in-a-hat"}, layout: "flipper")
    end
  end
end

describe Mascot::SitemapController, type: :controller do
  context "existing templated page" do
    render_views
    before { get :show, path: "/time" }
    let(:resource) { Mascot.configuration.sitemap.find_by_request_path("/time") }
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
    context "@_mascot_locals assignment" do
      subject { assigns(:_mascot_locals) }
      it ":current_page" do
        expect(subject[:current_page].file_path).to eql(resource.file_path)
      end
      it ":sitemap" do
        expect(subject[:sitemap]).to eql(Mascot.configuration.sitemap)
      end
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
