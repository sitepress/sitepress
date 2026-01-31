require "spec_helper"

RSpec.describe Sitepress::Resources do
  let(:node) { Sitepress::Node.new }
  subject(:resources) { node.resources }

  describe "#initialize" do
    it "starts empty" do
      expect(resources).to be_empty
    end

    it "has size 0" do
      expect(resources.size).to eq(0)
    end
  end

  describe "#add_asset" do
    let(:asset_path) { "spec/sites/sample/pages/test.html.haml" }
    let(:asset) { Sitepress::Asset.new(path: asset_path) }

    it "adds a resource" do
      resources.add_asset(asset)
      expect(resources.size).to eq(1)
    end

    it "returns the added resource" do
      result = resources.add_asset(asset)
      expect(result).to be_a(Sitepress::Resource)
    end

    it "uses asset format by default" do
      resources.add_asset(asset)
      expect(resources.formats).to include(:html)
    end

    it "allows overriding format" do
      resources.add_asset(asset, format: :xml)
      expect(resources.formats).to include(:xml)
    end
  end

  describe "#add" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }
    let(:resource) { Sitepress::Resource.new(asset: asset, node: node, format: :html) }

    it "adds a resource" do
      resources.add(resource)
      expect(resources).to include(resource)
    end

    it "raises ExistingRequestPathError when adding duplicate format" do
      resources.add(resource)
      duplicate = Sitepress::Resource.new(asset: asset, node: node, format: :html)

      expect { resources.add(duplicate) }.to raise_error(Sitepress::ExistingRequestPathError)
    end

    it "allows different formats for same node" do
      resources.add(resource)
      xml_resource = Sitepress::Resource.new(asset: asset, node: node, format: :xml)
      resources.add(xml_resource)

      expect(resources.size).to eq(2)
    end
  end

  describe "#format" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    before do
      resources.add_asset(asset, format: :html)
    end

    it "retrieves resource by format symbol" do
      expect(resources.format(:html)).to be_a(Sitepress::Resource)
    end

    it "retrieves resource by format string" do
      expect(resources.format("html")).to be_a(Sitepress::Resource)
    end

    it "returns nil for missing format" do
      expect(resources.format(:xml)).to be_nil
    end
  end

  describe "#format?" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    before do
      resources.add_asset(asset, format: :html)
    end

    it "returns true for existing format" do
      expect(resources.format?(:html)).to be true
    end

    it "returns false for missing format" do
      expect(resources.format?(:xml)).to be false
    end
  end

  describe "#formats" do
    let(:html_asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }
    let(:txt_asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/text.txt") }

    it "returns empty array when no resources" do
      expect(resources.formats).to eq([])
    end

    it "returns all formats" do
      resources.add_asset(html_asset, format: :html)
      resources.add_asset(txt_asset, format: :txt)

      expect(resources.formats).to match_array([:html, :txt])
    end
  end

  describe "#remove" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    before do
      resources.add_asset(asset, format: :html)
    end

    it "removes resource by format" do
      resources.remove(:html)
      expect(resources).to be_empty
    end

    it "removes resource by string format" do
      resources.remove("html")
      expect(resources).to be_empty
    end

    it "returns nil when format not found" do
      expect(resources.remove(:xml)).to be_nil
    end
  end

  describe "#mime_type" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    before do
      resources.add_asset(asset, format: :html)
    end

    it "finds resource by MIME type" do
      mime = MIME::Types.type_for("html").first
      expect(resources.mime_type(mime)).to be_a(Sitepress::Resource)
    end

    it "returns nil for non-matching MIME type" do
      mime = MIME::Types.type_for("xml").first
      expect(resources.mime_type(mime)).to be_nil
    end
  end

  describe "#each" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    it "iterates over resources" do
      resources.add_asset(asset, format: :html)
      resources.add_asset(asset, format: :xml)

      yielded = []
      resources.each { |r| yielded << r }

      expect(yielded.size).to eq(2)
      expect(yielded).to all(be_a(Sitepress::Resource))
    end

    it "is Enumerable" do
      expect(resources).to be_a(Enumerable)
    end
  end

  describe "#flatten" do
    let(:site) { Sitepress::Site.new(root_path: "spec/sites/tree") }

    it "returns all resources from node and children" do
      root_resources = site.root.resources.flatten
      expect(root_resources.size).to be > 1
    end

    it "includes nested resources" do
      root_resources = site.root.resources.flatten
      paths = root_resources.map(&:request_path)

      expect(paths).to include("/")
      expect(paths).to include("/about")
      expect(paths).to include("/vehicles/cars")
    end
  end

  describe "#clear" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    it "removes all resources" do
      resources.add_asset(asset, format: :html)
      resources.add_asset(asset, format: :xml)

      resources.clear

      expect(resources).to be_empty
    end
  end

  describe "#inspect" do
    let(:asset) { Sitepress::Asset.new(path: "spec/sites/sample/pages/test.html.haml") }

    it "returns a string representation" do
      resources.add_asset(asset, format: :html)
      expect(resources.inspect).to include("Sitepress::Resources")
    end
  end
end
