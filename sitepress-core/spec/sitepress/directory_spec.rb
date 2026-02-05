require "spec_helper"

RSpec.describe Sitepress::Directory do
  let(:path) { "spec/sites/sample/pages" }
  let(:node) { Sitepress::Node.new }
  subject(:directory) { Sitepress::Directory.new(path) }

  describe "#initialize" do
    it "creates AssetPaths from path" do
      expect(directory.asset_paths).to be_a(Sitepress::AssetPaths)
    end
  end

  describe "#mount" do
    before { directory.mount(node) }

    it "adds resources to the node tree" do
      all_resources = node.resources.flatten
      expect(all_resources.size).to be > 0
    end

    it "creates child nodes for files" do
      expect(node.children).not_to be_empty
    end

    it "maps file to correct node name" do
      test_node = node.child("test")
      expect(test_node).not_to be_nil
      expect(test_node.resources).not_to be_empty
    end

    it "creates resources with correct format" do
      test_node = node.child("test")
      resource = test_node.resources.format(:html)
      expect(resource).not_to be_nil
    end
  end

  describe "directory handling" do
    let(:path) { "spec/sites/tree/pages" }

    before { directory.mount(node) }

    it "creates nested nodes for directories" do
      vehicles_node = node.child("vehicles")
      expect(vehicles_node).not_to be_nil
    end

    it "maps deeply nested files" do
      smart_node = node.dig("vehicles", "cars", "compacts", "smart")
      expect(smart_node).not_to be_nil
      expect(smart_node.resources).not_to be_empty
    end

    it "maps files at multiple levels" do
      # Root level
      about_node = node.child("about")
      expect(about_node.resources).not_to be_empty

      # Nested level
      cars_node = node.dig("vehicles", "cars")
      expect(cars_node.resources).not_to be_empty
    end
  end

  describe "file type handling" do
    let(:path) { "spec/sites/tree/pages" }

    before { directory.mount(node) }

    it "handles .html.haml files" do
      about_node = node.child("about")
      resource = about_node.resources.format(:html)
      expect(resource).not_to be_nil
    end

    it "handles .html.md files" do
      camry_node = node.dig("vehicles", "cars", "camry")
      resource = camry_node.resources.format(:html)
      expect(resource).not_to be_nil
    end

    it "handles plain .html files" do
      rules_node = node.child("rules")
      resource = rules_node.resources.format(:html)
      expect(resource).not_to be_nil
    end

    it "handles .xml files" do
      cierra_node = node.dig("vehicles", "cars", "cierra")
      resource = cierra_node.resources.format(:xml)
      expect(resource).not_to be_nil
    end

    it "handles multiple formats for same node" do
      index_node = node.child("index")
      expect(index_node.resources.format(:html)).not_to be_nil
      expect(index_node.resources.format(:xml)).not_to be_nil
    end
  end

  describe "asset creation" do
    let(:path) { "spec/sites/sample/pages" }

    before { directory.mount(node) }

    it "creates assets with correct paths" do
      test_node = node.child("test")
      resource = test_node.resources.format(:html)
      expect(resource.asset.path.to_s).to include("test.html.haml")
    end
  end

  describe "ignores filtered files" do
    let(:path) { "spec/sites/sample/pages" }

    before { directory.mount(node) }

    it "does not create nodes for swap files" do
      all_resources = node.resources.flatten
      paths = all_resources.map { |r| r.asset.path.to_s }
      expect(paths).not_to include(a_string_ending_with(".swp"))
    end

    it "does not create nodes for backup files" do
      all_resources = node.resources.flatten
      paths = all_resources.map { |r| r.asset.path.to_s }
      expect(paths).not_to include(a_string_ending_with("~"))
    end
  end

  describe "backwards compatibility" do
    it "AssetNodeMapper is an alias for Directory" do
      expect(Sitepress::AssetNodeMapper).to eq(Sitepress::Directory)
    end
  end
end
