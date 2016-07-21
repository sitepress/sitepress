require 'spec_helper'

describe Mascot do
  it 'has a version number' do
    expect(Mascot::VERSION).not_to be nil
  end

  context Mascot::Frontmatter do
    context "con frontmatter" do
      subject { Mascot::Frontmatter.new File.read "spec/pages/test.html.haml" }
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
      subject { Mascot::Frontmatter.new File.read "spec/pages/sin_frontmatter.html.haml" }
      it "parses data" do
        expect(subject.data).to eql({})
      end
      it "parses body" do
        expect(subject.body).to_not be_nil
      end
    end
  end

  context Mascot::Resource do
    subject { Mascot::Resource.new(file_path: "spec/pages/test.html.haml", request_path: "/test") }
    describe "#locals" do
      it "has :current_page key" do
        expect(subject.locals).to have_key(:current_page)
      end
      it "has Binding as :current_page type" do
        expect(subject.locals[:current_page]).to be_instance_of Mascot::Resource::Binding
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

  context Mascot::Sitemap do
    subject { Mascot::Sitemap.new(file_path: "spec/pages") }
    it "has 2 resources" do
      expect(subject.resources.first.request_path).to eql("/sin_frontmatter")
    end
    it "globs resources" do
      expect(subject.resources("*sin_frontmatter*").size).to eql(1)
    end
  end

  require 'rack/test'
  context Mascot::Server do
    include Rack::Test::Methods
    let(:sitemap) { Mascot::Sitemap.new(file_path: "spec/pages", request_path: "/fizzy") }

    def app
      Mascot::Server.new(sitemap: sitemap)
    end

    let(:request_path) { "/fizzy/test" }

    it "gets page" do
      get request_path
      expect(last_response.status).to eql(200)
    end
  end

  context Mascot::Rails::RouteConstraint do
    let(:sitemap) { Mascot::Sitemap.new(file_path: "spec/pages") }
    let(:route_constraint) { Mascot::Rails::RouteConstraint.new(sitemap) }

    context "#matches?" do
      it "returns true if match" do
        request = double("request", path: "/test")
        expect(route_constraint.matches?(request)).to be(true)
      end
      it "returns false if not match" do
        request = double("request", path: "/does-not-exist")
        expect(route_constraint.matches?(request)).to be(false)
      end
    end
  end
end
