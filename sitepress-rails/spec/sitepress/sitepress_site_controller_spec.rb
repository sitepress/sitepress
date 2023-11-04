require "spec_helper"

describe Sitepress::SiteController, type: :controller do
  # Rails 5 introduces a new format of calling the `get` rspec helper method.
  def get_resource(path)
    request.env["PATH_INFO"] = path
    if Gem::Version.new(Rails.version) >= Gem::Version.new("5.0.0")
      get :show, params: { resource_path: path }
    else
      get :show, resource_path: path
    end
  end

  let(:site) { Sitepress.configuration.site }

  context "templated page" do
    render_views
    before { get_resource "/time" }
    let(:resource) { site.get("/time") }
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
      expect(response.content_type).to include("text/html")
    end
    context "helper methods" do
      subject { @controller }
      it "#current_page" do
        expect(subject.send(:current_page).asset.path).to eql(resource.asset.path)
      end
      it "#site" do
        expect(subject.send(:site)).to eql(site)
      end
    end
  end

  context "phlex layout wrapped page" do
    render_views
    before { get_resource "/phlex" }
    let(:resource) { site.get("/phlex") }
    it "is status 200" do
      expect(response.status).to eql(200)
    end
    it "renders body" do
      expect(response.body).to include("<h1>Hello from Phlex wrapper layout</h1>")
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
    it "renders default 'layouts/application' layout" do
      expect(response.body).to include("<title>Dummy</title>")
    end
    it "responds with content type" do
      expect(response.content_type).to include("text/html")
    end
  end

  context "non-existent page" do
    it "is status 404" do
      expect {
        get_resource "/non-existent"
      }.to raise_exception(ActionController::RoutingError)
    end
  end

  context "paths" do
    context "view_paths" do
      subject { Sitepress::SiteController.view_paths.map(&:path) }
      it { is_expected.to include(site.root_path.to_s) }
      it { is_expected.to include(site.pages_path.to_s) }
    end
    context "helper_paths" do
      subject{ Sitepress::SiteController.helpers_path }
      it { is_expected.to include(site.helpers_path.to_s) }
      it "has site#helper_paths in ActiveSupport::Dependencies.autoload_paths" do
        expect(ActiveSupport::Dependencies.autoload_paths).to include(site.helpers_path.to_s)
      end
    end
  end

  it "builds site once" do
    allow(site).to receive(:root).once.and_return(site.root)
    get_resource "/all_pages"
  end
end
