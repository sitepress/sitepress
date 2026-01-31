require "spec_helper"

RSpec.describe Sitepress::RailsConfiguration do
  subject(:config) { described_class.new }

  describe "DEFAULT_SITE_ROOT" do
    it "is app/content" do
      expect(described_class::DEFAULT_SITE_ROOT).to eq("app/content")
    end
  end

  describe "#initialize" do
    it "sets cache_resources to true by default" do
      expect(config.cache_resources).to be true
    end
  end

  describe "#cache_resources" do
    it "can be set to false" do
      config.cache_resources = false
      expect(config.cache_resources).to be false
    end

    it "can be set to true" do
      config.cache_resources = true
      expect(config.cache_resources).to be true
    end
  end

  describe "#parent_engine" do
    it "defaults to Rails.application" do
      expect(config.parent_engine).to eq(Rails.application)
    end

    it "can be set to a custom engine" do
      custom_engine = double("engine")
      config.parent_engine = custom_engine
      expect(config.parent_engine).to eq(custom_engine)
    end
  end

  describe "#site" do
    it "returns a Sitepress::Site" do
      expect(config.site).to be_a(Sitepress::Site)
    end

    it "uses default root path" do
      expect(config.site.root_path.to_s).to include("app/content")
    end

    it "can be set to a custom site" do
      custom_site = double("site")
      config.site = custom_site
      expect(config.site).to eq(custom_site)
    end

    it "memoizes the site" do
      site1 = config.site
      site2 = config.site
      expect(site1).to equal(site2)
    end
  end

  describe "#manifest_file_path" do
    it "returns path to manifest.js" do
      expect(config.manifest_file_path.to_s).to end_with("config/manifest.js")
    end

    it "is relative to site assets path" do
      expect(config.manifest_file_path.to_s).to include("assets")
    end
  end
end

RSpec.describe "Sitepress.configuration" do
  after do
    Sitepress.reset_configuration
  end

  describe ".configuration" do
    it "returns a RailsConfiguration" do
      expect(Sitepress.configuration).to be_a(Sitepress::RailsConfiguration)
    end

    it "memoizes the configuration" do
      config1 = Sitepress.configuration
      config2 = Sitepress.configuration
      expect(config1).to equal(config2)
    end
  end

  describe ".reset_configuration" do
    it "clears the configuration" do
      config1 = Sitepress.configuration
      Sitepress.reset_configuration
      config2 = Sitepress.configuration
      expect(config1).not_to equal(config2)
    end
  end

  describe ".site" do
    it "delegates to configuration.site" do
      expect(Sitepress.site).to eq(Sitepress.configuration.site)
    end
  end
end
