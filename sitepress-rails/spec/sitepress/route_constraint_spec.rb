require "spec_helper"

describe Sitepress::RouteConstraint do
  def request_for(path)
    double("request", path: path)
  end

  context "with an explicit site" do
    let(:subject) { Sitepress::RouteConstraint.new(site: Sitepress.site) }

    it "returns true if match" do
      expect(subject.matches?(request_for("/time"))).to be(true)
    end

    it "returns false if not match" do
      expect(subject.matches?(request_for("/does-not-exist"))).to be(false)
    end
  end

  context "with a controller name" do
    let(:subject) { Sitepress::RouteConstraint.new(controller: "sitepress/site") }

    it "resolves the controller class lazily and reads .site" do
      expect(subject.site).to eq(Sitepress::SiteController.site)
    end

    it "matches via the resolved controller's site" do
      expect(subject.matches?(request_for("/time"))).to be(true)
    end
  end

  context "with a controller bound to a non-default site" do
    # Define a constant subclass so the constraint can constantize it
    # via the controller name string.
    before do
      bound_site = Sitepress::Site.new(root_path: "spec/dummy/app/content")
      stub_const("BoundSiteController", Class.new(Sitepress::SiteController) do
        self.site = bound_site
      end)
    end

    after { Sitepress.reset_configuration }

    let(:subject) { Sitepress::RouteConstraint.new(controller: "bound_site") }

    it "resolves the bound site (not Sitepress.site) via the controller class" do
      expect(subject.site).to equal(BoundSiteController.site)
      expect(subject.site).not_to equal(Sitepress.site)
    end

    it "uses the bound site for matches?" do
      # The bound site is the dummy app's content tree, so /time
      # should resolve via the bound site exactly like the default does.
      expect(subject.matches?(request_for("/time"))).to be(true)
    end
  end

  context "with path_prefix" do
    let(:subject) { Sitepress::RouteConstraint.new(site: Sitepress.site, path_prefix: "/admin/docs") }

    it "returns true when path matches after stripping prefix" do
      expect(subject.matches?(request_for("/admin/docs/time"))).to be(true)
    end

    it "returns true for nested paths with prefix" do
      expect(subject.matches?(request_for("/admin/docs/hi"))).to be(true)
    end

    it "returns false when path doesn't match" do
      expect(subject.matches?(request_for("/admin/docs/does-not-exist"))).to be(false)
    end

    it "returns false when prefix doesn't match" do
      expect(subject.matches?(request_for("/other/path"))).to be(false)
    end

    it "strips prefix and looks up root" do
      expect(subject.send(:resource_path, request_for("/admin/docs"))).to eq("/")
    end
  end

  context "without site or controller" do
    it "raises when site is requested" do
      expect { Sitepress::RouteConstraint.new.site }.to raise_error(ArgumentError, /site:.*controller:/)
    end
  end
end
