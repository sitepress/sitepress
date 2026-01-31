require "spec_helper"

RSpec.describe Sitepress::BuildPaths do
  let(:site) { Sitepress.site }

  # Helper to get a resource by path
  def resource_for(request_path)
    site.resources.get(request_path)
  end

  describe Sitepress::BuildPaths::RootPath do
    describe "#path" do
      context "with a page resource at root level" do
        let(:resource) { resource_for("/hi") }
        subject(:build_path) { described_class.new(resource) }

        it "returns filename only (no parent directories)" do
          # /hi has no parent nodes (other than root), so lineage is empty
          expect(build_path.path).to eq("index.html")
        end
      end

      context "with another page resource" do
        let(:resource) { resource_for("/time") }
        subject(:build_path) { described_class.new(resource) }

        it "returns index.html for default format" do
          expect(build_path.path).to eq("index.html")
        end
      end
    end

    describe "#filename" do
      context "with html format (default)" do
        let(:resource) { resource_for("/hi") }
        subject(:build_path) { described_class.new(resource) }

        it "returns filename with format" do
          expect(build_path.filename).to eq("index.html")
        end
      end
    end

    describe "#resource" do
      let(:resource) { resource_for("/hi") }
      subject(:build_path) { described_class.new(resource) }

      it "returns the resource" do
        expect(build_path.resource).to eq(resource)
      end
    end

    describe "#node" do
      let(:resource) { resource_for("/hi") }
      subject(:build_path) { described_class.new(resource) }

      it "delegates to resource" do
        expect(build_path.node).to eq(resource.node)
      end
    end

    describe "#format" do
      let(:resource) { resource_for("/hi") }
      subject(:build_path) { described_class.new(resource) }

      it "delegates to resource" do
        expect(build_path.format).to eq(resource.format)
      end
    end
  end

  describe Sitepress::BuildPaths::IndexPath do
    describe "#path" do
      context "with a page resource at root level" do
        let(:resource) { resource_for("/hi") }
        subject(:build_path) { described_class.new(resource) }

        it "returns path with node name and format" do
          # For root-level resource, lineage is empty, so path is just filename
          expect(build_path.path).to eq("hi.html")
        end
      end
    end

    describe "#filename" do
      context "with html format (default)" do
        let(:resource) { resource_for("/hi") }
        subject(:build_path) { described_class.new(resource) }

        it "returns filename with node name and format" do
          expect(build_path.filename).to eq("hi.html")
        end
      end
    end

    describe "#filename_without_format" do
      let(:resource) { resource_for("/hi") }
      subject(:build_path) { described_class.new(resource) }

      it "returns node name" do
        expect(build_path.send(:filename_without_format)).to eq("hi")
      end
    end
  end

  describe Sitepress::BuildPaths::DirectoryIndexPath do
    describe "#path" do
      context "with a page resource at root level" do
        let(:resource) { resource_for("/hi") }
        subject(:build_path) { described_class.new(resource) }

        it "returns path with directory structure" do
          # For root-level resource with default format, creates hi/index.html
          expect(build_path.path).to eq("hi/index.html")
        end
      end
    end

    describe "#filename_with_default_format" do
      let(:resource) { resource_for("/hi") }
      subject(:build_path) { described_class.new(resource) }

      it "creates directory structure for default format" do
        filename = build_path.send(:filename_with_default_format)
        expect(filename).to eq("hi/index.html")
      end
    end

    describe "inheritance" do
      it "inherits from IndexPath" do
        expect(described_class.superclass).to eq(Sitepress::BuildPaths::IndexPath)
      end
    end
  end

  describe "class hierarchy" do
    it "IndexPath inherits from RootPath" do
      expect(Sitepress::BuildPaths::IndexPath.superclass).to eq(Sitepress::BuildPaths::RootPath)
    end

    it "DirectoryIndexPath inherits from IndexPath" do
      expect(Sitepress::BuildPaths::DirectoryIndexPath.superclass).to eq(Sitepress::BuildPaths::IndexPath)
    end
  end
end
