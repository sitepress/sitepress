require 'spec_helper'

describe Beams do
  it 'has a version number' do
    expect(Beams::VERSION).not_to be nil
  end

  context Beams::Frontmatter do
    context "con frontmatter" do
      subject { Beams::Frontmatter.new File.read "spec/pages/test.html.haml" }
      it "parses data" do
        expect(subject.data).to eql({
          "title" => "Name",
          "meta" => {
            "keywords" => "One" }})
      end
      it "parses body" do
        expect(subject.body).to_not be_nil
      end
    end
    context "sin frontmatter" do # That's Spanish for pages that don't have Frontmatter.
      subject { Beams::Frontmatter.new File.read "spec/pages/sin_frontmatter.html.haml" }
      it "parses data" do
        expect(subject.data).to eql({})
      end
      it "parses body" do
        expect(subject.body).to_not be_nil
      end
    end
  end

  context Beams::Resource do
    subject { Beams::Resource.new(file_path: "spec/pages/test.html.haml", request_path: "/test") }
    describe "#locals" do
      it "has :current_page key" do
        expect(subject.locals).to have_key(:current_page)
      end
      it "has Binding as :current_page type" do
        expect(subject.locals[:current_page]).to be_instance_of Beams::Resource::Binding
      end
    end
    describe "#content_type" do
      it "is text/html" do
        expect(subject.content_type).to eql("text/html")
      end
    end
    it "has data" do
      expect(subject.data["title"]).to eql("Name")
    end
    it "parses body" do
      expect(subject.body).to include("This is just some content")
    end
  end

  context Beams::Sitemap do
    subject { Beams::Sitemap.new(root: "spec/pages") }
    it "has 2 resources" do
      expect(subject.resources.first.request_path).to eql("/sin_frontmatter")
    end
    it "globs resources" do
      expect(subject.resources("*sin_frontmatter*").size).to eql(1)
    end
  end

  require 'rack/test'
  context Beams::Server do
    include Rack::Test::Methods
    let(:sitemap) { Beams::Sitemap.new(root: "spec/pages") }

    def app
      Beams::Server.new(sitemap)
    end

    let(:request_path) { "/test" }

    it "gets page" do
      get request_path
      expect(last_response.status).to eql(200)
    end
  end
end
