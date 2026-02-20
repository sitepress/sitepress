require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Model do
  let(:model) { PageModel }

  describe "#all" do
    subject { model.all }
    context "models" do
      it "has correct count" do
        expect(subject.count).to eql 4
      end
      it "is instances of model" do
        expect(subject.first).to be_instance_of PageModel
      end
      it "returns a Collection" do
        expect(subject).to be_a(Sitepress::Models::Collection)
      end
    end
    describe "#resources" do
      subject { model.all.resources }
      it "has correct count" do
        expect(subject.count).to eql 4
      end
      it "is instances of pages" do
        expect(subject.first).to be_instance_of Sitepress::Resource
      end
    end
  end

  describe "#save" do
    subject { model.first }
    it "saves" do
      subject.save
    end
  end

  describe "#data" do
    subject { model.get("time") }
    it "defines #title method" do
      expect(subject.title).to eql "Tick tock, tick tock"
    end
  end

  describe ".get" do
    subject { model.first }
    context "no page" do
      it "returns nil" do
        expect(model.get("does-not-exist")).to be_nil
      end
    end
    context "existing page" do
      it "returns page" do
        expect(model.get("hi")).to be_a(PageModel)
      end
    end
  end

  describe ".collection" do
    it "returns a Collection" do
      test_model = Class.new(Sitepress::Model)
      result = test_model.collection { test_model.site.glob("*.html*") }
      expect(result).to be_a(Sitepress::Models::Collection)
    end

    it "returns model instances from the collection" do
      test_model = Class.new(Sitepress::Model)
      result = test_model.collection { test_model.site.glob("*.html*") }
      expect(result.first).to be_a(test_model)
    end

    it "can be chained with enumerable methods" do
      test_model = Class.new(Sitepress::Model)
      result = test_model.collection { test_model.site.glob("*.html*") }
      paths = result.map(&:request_path)
      expect(paths).to be_an(Array)
      expect(paths).to all(be_a(String))
    end

    it "raises without a block" do
      test_model = Class.new(Sitepress::Model)
      expect { test_model.collection }.to raise_error(ArgumentError)
    end
  end

  describe ".glob" do
    it "returns a Collection" do
      expect(model.glob("*.html*")).to be_a(Sitepress::Models::Collection)
    end

    it "returns model instances" do
      result = model.glob("*.html*")
      expect(result.first).to be_a(PageModel)
    end

    it "filters resources by glob pattern" do
      result = model.glob("hi.html")
      expect(result.count).to eql 1
      expect(result.first.request_path).to eql "/hi"
    end
  end

  describe "chaining" do
    it "supports standard enumerable methods" do
      result = model.all.select { |page| page.request_path.include?("hi") }
      expect(result).to be_an(Array)
      expect(result).to all(be_a(PageModel))
    end

    it "supports map" do
      paths = model.all.map(&:request_path)
      expect(paths).to be_an(Array)
      expect(paths).to all(be_a(String))
    end

    it "supports each" do
      count = 0
      model.all.each { |page| count += 1 }
      expect(count).to eql 4
    end

    it "supports first" do
      expect(model.all.first).to be_a(PageModel)
    end

    it "supports count" do
      expect(model.all.count).to be_a(Integer)
    end

    it "can convert to array" do
      array = model.all.to_a
      expect(array).to be_an(Array)
      expect(array).to all(be_a(PageModel))
    end
  end

  describe "model equality" do
    it "considers models equal if they have the same page and class" do
      page1 = model.first
      page2 = model.get(page1.request_path)
      expect(page1).to eq(page2)
    end

    it "considers models unequal if they have different pages" do
      pages = model.all.to_a
      if pages.size >= 2
        expect(pages[0]).not_to eq(pages[1])
      end
    end
  end
end
