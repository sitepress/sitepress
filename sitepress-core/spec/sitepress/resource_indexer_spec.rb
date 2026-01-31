require "spec_helper"

RSpec.describe Sitepress::ResourceIndexer do
  let(:site) { Sitepress::Site.new(root_path: "spec/sites/tree") }
  let(:root_path) { site.root_path.join("pages") }
  subject(:indexer) { Sitepress::ResourceIndexer.new(node: site.root, root_path: root_path) }

  describe "#initialize" do
    it "sets root_path as Pathname" do
      expect(indexer.root_path).to be_a(Pathname)
    end
  end

  describe "Enumerable delegation" do
    it "responds to #each" do
      expect(indexer).to respond_to(:each)
    end

    it "responds to #size" do
      expect(indexer.size).to be > 0
    end

    it "responds to #count" do
      expect(indexer.count).to eq(indexer.size)
    end

    it "responds to #[]" do
      expect(indexer[0]).to be_a(Sitepress::Resource)
    end

    it "responds to #first via Enumerable" do
      expect(indexer.first).to be_a(Sitepress::Resource)
    end

    it "responds to #last" do
      expect(indexer.last).to be_a(Sitepress::Resource)
    end

    it "responds to #fetch" do
      expect(indexer.fetch(0)).to be_a(Sitepress::Resource)
    end

    it "is Enumerable" do
      expect(indexer).to be_a(Enumerable)
    end

    it "can map over resources" do
      paths = indexer.map(&:request_path)
      expect(paths).to all(be_a(String))
    end
  end

  describe "#get" do
    it "retrieves resource by request path" do
      resource = indexer.get("/about")
      expect(resource).to be_a(Sitepress::Resource)
      expect(resource.request_path).to eq("/about")
    end

    it "retrieves root resource" do
      resource = indexer.get("/")
      expect(resource).to be_a(Sitepress::Resource)
    end

    it "retrieves nested resource" do
      resource = indexer.get("/vehicles/cars")
      expect(resource).to be_a(Sitepress::Resource)
      expect(resource.request_path).to eq("/vehicles/cars")
    end

    it "returns nil for non-existent path" do
      expect(indexer.get("/does-not-exist")).to be_nil
    end
  end

  describe "#glob" do
    it "returns resources matching glob pattern" do
      resources = indexer.glob("**/*.html.haml")
      expect(resources).to all(be_a(Sitepress::Resource))
      expect(resources.size).to be > 0
    end

    it "returns empty array for non-matching pattern" do
      resources = indexer.glob("**/*.nonexistent")
      expect(resources).to eq([])
    end

    it "matches specific file patterns" do
      resources = indexer.glob("**/about.html.haml")
      expect(resources.size).to eq(1)
      expect(resources.first.request_path).to eq("/about")
    end

    it "matches nested directories" do
      resources = indexer.glob("vehicles/**/*.md")
      expect(resources.size).to be > 0
      resources.each do |resource|
        expect(resource.request_path).to start_with("/vehicles")
      end
    end

    it "matches multiple extensions" do
      resources = indexer.glob("**/*.{html,xml}")
      expect(resources.size).to be > 0
    end
  end

  describe "resource collection" do
    it "includes all resources from the site" do
      paths = indexer.map(&:request_path)

      expect(paths).to include("/")
      expect(paths).to include("/about")
      expect(paths).to include("/rules")
      expect(paths).to include("/vehicles/cars")
    end

    it "includes resources with different formats" do
      paths = indexer.map(&:request_path)

      expect(paths).to include("/")
      expect(paths).to include("/index.xml")
    end
  end
end
