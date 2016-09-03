require "spec_helper"

describe Mascot::SiteController, type: :controller do
  context "templated page" do
    render_views
    before { get :show, resource_path: "/time" }
    let(:resource) { Mascot.configuration.site.get("/time") }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Tick tock, tick tock</h1>")
    end
    it "renders layout" do
      expect(response.body).to include("<title>Test layout</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to eql("text/html")
    end
    context "helper methods" do
      subject { @controller }
      it "#current_page" do
        expect(subject.send(:current_page).asset.path).to eql(resource.asset.path)
      end
      it "#root" do
        expect(subject.send(:root)).to eql(Mascot.configuration.root)
      end
    end
  end

  context "static page" do
    render_views
    before { get :show, resource_path: "/hi" }
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
        get :show, resource_path: "/non-existent"
      }.to raise_exception(ActionController::RoutingError)
    end
  end
end
