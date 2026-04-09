require "spec_helper"

describe Sitepress::Sites do
  subject(:sites) { described_class.new }

  let(:admin_docs) { Sitepress::Site.new(root_path: "spec/dummy/app/content") }
  let(:marketing)  { Sitepress::Site.new(root_path: "spec/dummy/app/marketing") }

  describe "#<<" do
    it "registers a Site" do
      sites << admin_docs
      expect(sites.to_a).to include(admin_docs)
    end

    it "returns self so multiple registrations chain" do
      expect(sites << admin_docs << marketing).to equal(sites)
      expect(sites.to_a).to eq([admin_docs, marketing])
    end

    it "raises ArgumentError when something other than a Site is pushed" do
      expect { sites << "app/content/admin_docs" }.to raise_error(ArgumentError, /expects a Sitepress::Site/)
      expect { sites << :admin_docs }.to raise_error(ArgumentError, /expects a Sitepress::Site/)
      expect { sites << nil }.to raise_error(ArgumentError, /expects a Sitepress::Site/)
    end

    it "warns via Rails.logger when called after the engine's path-setup pass" do
      Sitepress.configuration.instance_variable_set(:@boot_paths_registered, true)
      expect(Rails.logger).to receive(:warn).with(/path-setup pass/)
      Sitepress.sites << admin_docs
    ensure
      Sitepress.configuration.instance_variable_set(:@boot_paths_registered, false)
    end

    it "does not warn when called before the engine's path-setup pass" do
      Sitepress.configuration.instance_variable_set(:@boot_paths_registered, false)
      expect(Rails.logger).not_to receive(:warn)
      Sitepress.sites << admin_docs
    end
  end

  describe "#fetch" do
    before { sites << admin_docs }

    it "returns the Site whose root_path matches the given string" do
      expect(sites.fetch("spec/dummy/app/content")).to equal(admin_docs)
    end

    it "accepts a Pathname interchangeably with a string" do
      expect(sites.fetch(Pathname.new("spec/dummy/app/content"))).to equal(admin_docs)
    end

    it "raises NotFoundError when no Site matches" do
      expect { sites.fetch("nope") }.to raise_error(Sitepress::NotFoundError, /nope/)
    end

    it "lists registered paths in the error message" do
      expect { sites.fetch("nope") }.to raise_error(Sitepress::NotFoundError, /spec\/dummy\/app\/content/)
    end
  end

  describe "Enumerable" do
    it "iterates over registered Sites" do
      sites << admin_docs << marketing
      expect(sites.to_a).to eq([admin_docs, marketing])
    end

    it "supports map" do
      sites << admin_docs << marketing
      expect(sites.map { |s| s.root_path.to_s }).to eq(["spec/dummy/app/content", "spec/dummy/app/marketing"])
    end
  end

end

describe "Sitepress.sites" do
  after { Sitepress.reset_configuration }

  it "is a Sitepress::Sites instance" do
    expect(Sitepress.sites).to be_a(Sitepress::Sites)
  end

  it "is reset by Sitepress.reset_configuration" do
    Sitepress.sites << Sitepress::Site.new(root_path: "spec/dummy/app/content")
    Sitepress.reset_configuration
    expect(Sitepress.sites.to_a).to be_empty
  end
end

describe Sitepress::SiteController, "site binding" do
  after { Sitepress.reset_configuration }

  it "defaults to Sitepress.site when nothing is assigned" do
    expect(Sitepress::SiteController.site).to eq(Sitepress.site)
  end

  it "lets a subclass bind itself to a registered site via self.site=" do
    site = Sitepress::Site.new(root_path: "spec/dummy/app/content")
    Sitepress.sites << site
    klass = Class.new(Sitepress::SiteController) do
      self.site = Sitepress.sites.fetch("spec/dummy/app/content")
    end
    expect(klass.site).to equal(site)
  end

  it "prepends the bound site's view paths to this controller only" do
    site = Sitepress::Site.new(root_path: "spec/dummy/app/content")
    klass = Class.new(Sitepress::SiteController) do
      self.site = site
    end
    paths = klass.view_paths.map(&:to_s)
    expect(paths).to include(a_string_including("app/content"))
  end

  it "does not duplicate view paths when self.site= runs more than once" do
    # Simulates a Rails dev-mode class reload firing the writer twice.
    # The idempotency check inside SiteBinding#site= should keep the
    # path from being prepended a second time.
    site = Sitepress::Site.new(root_path: "spec/dummy/app/content")
    klass = Class.new(Sitepress::SiteController) do
      self.site = site
      self.site = site
    end
    matches = klass.view_paths.map(&:to_s).count { |p| p.include?("spec/dummy/app/content") }
    # `pages_path` and `root_path` each get prepended once, so we
    # expect at most 2 entries that mention the site directory — not 4.
    expect(matches).to be <= 2
  end

  it "subclasses without a binding still see the default site" do
    klass = Class.new(Sitepress::SiteController)
    expect(klass.site).to eq(Sitepress.site)
  end
end
