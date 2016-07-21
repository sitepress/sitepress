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
    it "has data" do
      expect(subject.data["title"]).to eql("Name")
    end
    it "parses body" do
      expect(subject.body).to include("This is just some content")
    end
    context "content types" do
      context "format and template" do
        subject { Mascot::Resource.new(file_path: "spec/pages/test.html.haml", request_path: "/test") }
        describe "#extensions" do
          it "returns [html, haml]" do
            expect(subject.extensions).to eql(%w[html haml])
          end
        end
        describe "#format_extension" do
          it "returns 'html'" do
            expect(subject.format_extension).to eql("html")
          end
        end
        describe "#template_extensions" do
          it "returns [haml]" do
            expect(subject.template_extensions).to eql(%w[haml])
          end
        end
        describe "#mime_type" do
          it "has html mime type" do
            expect(subject.mime_type).to eql(MIME::Types["text/html"].first)
          end
        end
      end
      context "format" do
        subject { Mascot::Resource.new(file_path: "spec/pages/text.txt", request_path: "/text") }
        describe "#extensions" do
          it "returns [txt]" do
            expect(subject.extensions).to eql(%w[txt])
          end
        end
        describe "#format_extension" do
          it "returns 'txt'" do
            expect(subject.format_extension).to eql("txt")
          end
        end
        describe "#template_extensions" do
          it "returns []" do
            expect(subject.template_extensions).to be_empty
          end
        end
        describe "#mime_type" do
          it "has plain mime type" do
            expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
          end
        end
      end
      context "none" do
        subject { Mascot::Resource.new(file_path: "spec/pages/nothing", request_path: "/nothing") }
        describe "#extensions" do
          it "is empty" do
            expect(subject.extensions).to be_empty
          end
        end
        describe "#format_extension" do
          it "is nil" do
            expect(subject.format_extension).to be_nil
          end
        end
        describe "#template_extensions" do
          it "is empty" do
            expect(subject.template_extensions).to be_empty
          end
        end
        describe "#mime_type" do
          it "is application/octet-stream" do
            expect(subject.mime_type).to eql(MIME::Types["application/octet-stream"].first)
          end
        end
      end
      context "mime type override " do
        subject { Mascot::Resource.new(file_path: "spec/pages/nothing", request_path: "/nothing", mime_type: MIME::Types["text/plain"]) }
        it "is text/plain" do
          expect(subject.mime_type).to eql(MIME::Types["text/plain"].first)
        end
      end
    end
  end

  context Mascot::Sitemap do
    subject { Mascot::Sitemap.new(file_path: "spec/pages") }
    let(:resource_count) { 4 }
    it "has 3 resources" do
      expect(subject.resources.size).to eql(resource_count)
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
