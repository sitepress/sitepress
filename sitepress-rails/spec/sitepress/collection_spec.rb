require "spec_helper"

describe Sitepress::Models::Collection do
  let(:model_class) { PageModel }
  let(:site) { Sitepress.site }
  let(:collection) do
    Sitepress::Models::Collection.new(model: model_class) do
      site.glob("**/*.html*")
    end
  end

  describe "#initialize" do
    it "accepts a model and resources block" do
      expect(collection).to be_a(Sitepress::Models::Collection)
    end

    it "stores the model class" do
      expect(collection.model).to eq(model_class)
    end
  end

  describe "#resources" do
    it "returns an array of resources" do
      expect(collection.resources).to be_an(Array)
    end

    it "returns Sitepress::Resource instances" do
      expect(collection.resources.first).to be_a(Sitepress::Resource)
    end

    it "calls the block passed to initialize" do
      block_called = false
      test_collection = Sitepress::Models::Collection.new(model: model_class) do
        block_called = true
        site.glob("*.html*")
      end
      test_collection.resources
      expect(block_called).to be true
    end
  end

  describe "#each" do
    it "yields model instances, not resources" do
      collection.each do |item|
        expect(item).to be_a(model_class)
        expect(item).not_to be_a(Sitepress::Resource)
      end
    end

    it "wraps each resource in the model class" do
      resources = collection.resources
      models = []
      collection.each { |model| models << model }
      
      expect(models.size).to eq(resources.size)
    end

    it "returns an enumerator when no block is given" do
      enumerator = collection.each
      expect(enumerator).to be_a(Enumerator)
    end

    it "can iterate over the enumerator" do
      enumerator = collection.each
      first_item = enumerator.next
      expect(first_item).to be_a(model_class)
    end
  end

  describe "Enumerable methods" do
    describe "#map" do
      it "maps over model instances" do
        paths = collection.map(&:request_path)
        expect(paths).to be_an(Array)
        expect(paths).to all(be_a(String))
      end

      it "returns results, not models" do
        paths = collection.map(&:request_path)
        expect(paths.first).to be_a(String)
        expect(paths.first).not_to be_a(model_class)
      end
    end

    describe "#select" do
      it "filters model instances" do
        filtered = collection.select { |page| page.request_path.include?("hi") }
        expect(filtered).to be_an(Array)
        expect(filtered).to all(be_a(model_class))
      end

      it "returns fewer items when filtered" do
        all_count = collection.count
        filtered = collection.select { |page| page.request_path.include?("hi") }
        expect(filtered.size).to be <= all_count
      end
    end

    describe "#reject" do
      it "filters out model instances" do
        rejected = collection.reject { |page| page.request_path.include?("hi") }
        expect(rejected).to be_an(Array)
        expect(rejected).to all(be_a(model_class))
      end
    end

    describe "#find" do
      it "finds a model instance" do
        result = collection.find { |page| page.request_path == "/hi" }
        expect(result).to be_a(model_class)
      end

      it "returns nil when not found" do
        result = collection.find { |page| page.request_path == "does-not-exist" }
        expect(result).to be_nil
      end
    end

    describe "#first" do
      it "returns the first model instance" do
        expect(collection.first).to be_a(model_class)
      end

      it "returns the same as accessing via each" do
        first_via_each = nil
        collection.each { |item| first_via_each = item; break }
        expect(collection.first).to eq(first_via_each)
      end
    end

    describe "#count" do
      it "returns the number of items" do
        expect(collection.count).to be_a(Integer)
        expect(collection.count).to be > 0
      end

      it "matches the resource count" do
        expect(collection.count).to eq(collection.resources.count)
      end
    end

    describe "#to_a" do
      it "converts to an array of models" do
        array = collection.to_a
        expect(array).to be_an(Array)
        expect(array).to all(be_a(model_class))
      end

      it "returns all items" do
        array = collection.to_a
        expect(array.size).to eq(collection.count)
      end
    end

    describe "#any?" do
      it "returns true when collection has items" do
        expect(collection.any?).to be true
      end

      it "can be used with a block" do
        result = collection.any? { |page| page.request_path == "/hi" }
        expect(result).to be true
      end
    end

    describe "#all?" do
      it "returns true when all items match" do
        result = collection.all? { |page| page.is_a?(model_class) }
        expect(result).to be true
      end

      it "returns false when not all items match" do
        result = collection.all? { |page| page.request_path == "/hi" }
        expect(result).to be false
      end
    end

    describe "#none?" do
      it "returns false when collection has items" do
        result = collection.none? { |page| page.is_a?(model_class) }
        expect(result).to be false
      end

      it "returns true when no items match" do
        result = collection.none? { |page| page.request_path == "does-not-exist" }
        expect(result).to be true
      end
    end
  end

  describe "chaining" do
    it "supports chaining multiple enumerable methods" do
      result = collection
        .select { |page| page.request_path.length > 0 }
        .map(&:request_path)
        .sort

      expect(result).to be_an(Array)
      expect(result).to all(be_a(String))
    end

    it "can chain with array methods after to_a" do
      result = collection.to_a.reverse.first
      expect(result).to be_a(model_class)
    end
  end

  describe "lazy evaluation" do
    it "doesn't call the resources block until enumeration" do
      block_called = false
      lazy_collection = Sitepress::Models::Collection.new(model: model_class) do
        block_called = true
        site.glob("*.html*")
      end
      
      expect(block_called).to be false
      lazy_collection.first
      expect(block_called).to be true
    end

    it "calls the resources block multiple times if accessed multiple times" do
      call_count = 0
      counting_collection = Sitepress::Models::Collection.new(model: model_class) do
        call_count += 1
        site.glob("*.html*")
      end
      
      counting_collection.first
      counting_collection.count
      expect(call_count).to eq(2)
    end
  end

  describe "with custom model" do
    let(:custom_model) do
      Class.new(Sitepress::Model) do
        def custom_method
          "custom"
        end
      end
    end

    let(:custom_collection) do
      Sitepress::Models::Collection.new(model: custom_model) do
        site.glob("*.html*")
      end
    end

    it "returns instances of the custom model" do
      expect(custom_collection.first).to be_a(custom_model)
    end

    it "has access to custom methods" do
      expect(custom_collection.first.custom_method).to eq("custom")
    end
  end

  describe "with empty results" do
    let(:empty_collection) do
      Sitepress::Models::Collection.new(model: model_class) do
        site.glob("does-not-exist-*.html")
      end
    end

    it "returns zero count" do
      expect(empty_collection.count).to eq(0)
    end

    it "returns nil for first" do
      expect(empty_collection.first).to be_nil
    end

    it "returns empty array for to_a" do
      expect(empty_collection.to_a).to eq([])
    end

    it "returns false for any?" do
      expect(empty_collection.any?).to be false
    end
  end
end