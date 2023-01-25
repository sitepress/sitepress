require "spec_helper"

context Sitepress::Data do
  let(:data) { Sitepress::Data.manage(unwrapped_data) }
  subject { data }

  context "blank hash" do
    let(:unwrapped_data) { {} }
    it { is_expected.to be_none }
    it "returns nil for non-existent keys" do
      expect(subject.title).to eql nil
    end
    describe "required keys" do
      it "raises exception" do
        expect{subject.title!}.to raise_error(KeyError)
      end
      it "returns default value" do
        expect(subject.title!("default")).to eql("default")
      end
      it "returns default block value" do
        expect(subject.title!{ "default" }).to eql("default")
      end
    end
  end

  context "blank array" do
    let(:unwrapped_data) { [] }
    it { is_expected.to be_none }
  end

  context "hash" do
    let(:unwrapped_data) do
      {
        "title" => "Hello",
        "description" => "Some data",
        colors: [
          1,
          "two",
          { number: 3 }
        ]
      } 
    end
    describe "required keys" do
      it "returns default value" do
        expect(subject.title!("default")).to eql("Hello")
      end
      it "returns default block value" do
        expect(subject.title!{ "default" }).to eql("Hello")
      end
    end
    describe "key presence" do
      it "returns true if data is present" do
        expect(subject.title?).to be true
      end
      it "returns true if data is not present" do
        expect(subject.nothing_exists?).to be false
      end
    end
    describe "Enumerable" do
      let(:key) { element.first }
      let(:value) { element.last }

      context "value element" do
        let(:element) { data.take(1).last }
        it "returns key" do
          expect(key).to eql("title")
        end
        it "returns value" do
          expect(value).to eql("Hello")
        end
      end
      context "data element" do
        let(:element) { data.take(3).last }
        it "returns key" do
          expect(key).to eql :colors
        end
        it "returns value" do
          expect(value[0]).to eql(1)
          expect(value[1]).to eql("two")
          expect(value[2]).to be_a(Sitepress::Data::Record)
        end
      end
    end
  end

  context "array" do
    let(:unwrapped_data) do
      [
        "dogs",
        :cats,
        { title: "The one", tags: %w[urgent critical] },
        [
          1,
          2,
          3
        ]
      ]
    end
    describe "Enumerable" do
      it "iterates values" do
        values = []
        data.each { |v| values << v }
        expect(values.count).to eq(4)
      end
      it "returns values" do
        expect(data[0]).to eql("dogs")
        expect(data[1]).to eql(:cats)
        expect(data[2]).to be_a(Sitepress::Data::Record)
        expect(data[3]).to be_a(Sitepress::Data::Collection)
      end
    end
  end
end