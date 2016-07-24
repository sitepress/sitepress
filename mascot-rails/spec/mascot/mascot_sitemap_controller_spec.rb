require "spec_helper"

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
