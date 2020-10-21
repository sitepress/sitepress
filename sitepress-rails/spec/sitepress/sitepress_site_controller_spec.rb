require "spec_helper"

describe Sitepress::SiteController, type: :controller do
  # Rails 5 introduces a new format of calling the `get` rspec helper method.
  def get_resource(path)
    if Gem::Version.new(Rails.version) >= Gem::Version.new("5.0.0")
      get :show, params: { resource_path: path }
    else
      get :show, resource_path: path
    end
  end

  context "templated page" do
    render_views
    before { get_resource "/time" }
    let(:resource) { Sitepress.site.get("/time") }
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
      it "#site" do
        expect(subject.send(:site)).to eql(Sitepress.site)
      end
    end
  end

  context "static page" do
    render_views
    before { get_resource "/hi" }
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
        get_resource "/non-existent"
      }.to raise_exception(ActionController::RoutingError)
    end
  end

  context "render cache" do
    context "cache_resources=true" do
      before { Sitepress.site.cache_resources = true }
      it "enables cache" do
        expect(Sitepress.site.cache_resources).to be true
        expect(Sitepress.site).to receive(:cache_resources=).with(true)
        expect(Sitepress.site).to receive(:cache_resources=).with(true)
        get_resource "/time"
        expect(Sitepress.site.cache_resources).to be true
      end
    end
    context "cache_resources=false" do
      before { Sitepress.site.cache_resources = false }
      it "enables cache" do
        expect(Sitepress.site.cache_resources).to be false
        expect(Sitepress.site).to receive(:cache_resources=).with(true)
        expect(Sitepress.site).to receive(:cache_resources=).with(false)
        get_resource "/time"
        expect(Sitepress.site.cache_resources).to be false
      end
    end

  end
end
