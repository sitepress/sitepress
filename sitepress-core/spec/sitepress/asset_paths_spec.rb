require "spec_helper"

RSpec.describe Sitepress::AssetPaths do
  let(:path) { "spec/sites/sample/pages" }
  subject(:asset_paths) { Sitepress::AssetPaths.new(path: path) }

  describe "#initialize" do
    it "sets path as Pathname" do
      expect(asset_paths.path).to be_a(Pathname)
    end
  end

  describe "Enumerable" do
    it "is Enumerable" do
      expect(asset_paths).to be_a(Enumerable)
    end

    it "iterates over paths" do
      paths = asset_paths.to_a
      expect(paths).to all(be_a(Pathname))
    end
  end

  describe "file filtering" do
    describe "ignores swap files" do
      it "excludes .swp files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).not_to include(a_string_ending_with(".swp"))
      end

      it "excludes ~ backup files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).not_to include(a_string_ending_with("~"))
      end
    end

    describe "ignores partial files" do
      let(:path) { "spec/sites/tree/pages" }

      it "excludes files starting with underscore" do
        paths = asset_paths.map { |p| p.basename.to_s }
        expect(paths).not_to include(a_string_starting_with("_"))
      end
    end

    describe "ignores system files" do
      it "excludes .DS_Store files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).not_to include(a_string_including(".DS_Store"))
      end

      it "excludes .git files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).not_to include(a_string_matching(/\.git/))
      end
    end

    describe "includes valid files" do
      it "includes .html.haml files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).to include(a_string_ending_with(".html.haml"))
      end

      it "includes .txt files" do
        paths = asset_paths.map(&:to_s)
        expect(paths).to include(a_string_ending_with(".txt"))
      end

      it "includes directories" do
        paths = asset_paths.select(&:directory?)
        expect(paths.size).to be >= 1
      end
    end
  end

  describe "IGNORE_PATTERNS" do
    it "includes swap file patterns" do
      expect(Sitepress::AssetPaths::IGNORE_PATTERNS).to include("**/*.swp")
      expect(Sitepress::AssetPaths::IGNORE_PATTERNS).to include("**/*~")
    end

    it "includes .DS_Store pattern" do
      expect(Sitepress::AssetPaths::IGNORE_PATTERNS).to include("**/.DS_Store")
    end

    it "includes .git pattern" do
      expect(Sitepress::AssetPaths::IGNORE_PATTERNS).to include("**/.git*")
    end

    it "includes .orig pattern" do
      expect(Sitepress::AssetPaths::IGNORE_PATTERNS).to include("**/*.orig")
    end
  end

  describe "PARTIAL_PREFIX" do
    it "is underscore" do
      expect(Sitepress::AssetPaths::PARTIAL_PREFIX).to eq("_")
    end
  end
end
