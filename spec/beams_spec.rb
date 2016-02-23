require 'spec_helper'

describe Beams do
  it 'has a version number' do
    expect(Beams::VERSION).not_to be nil
  end

  context Beams::Frontmatter do
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

  context Beams::Page do
    subject { Beams::Page.open("spec/pages/test.html.haml") }
    it "parses data" do
      expect(subject.dom.at_css("title").content).to eql("Name")
    end
    context "data pipeline" do
      before do
        subject.data_pipeline.add do |page|
          { "toc" => page.dom.css("h1,h2,h3,h4,h5,h6").map(&:content) }
        end
      end
      it "merges toc" do
        expect(subject.data["toc"]).to eql(["Hi", "There"])
      end
      it "preserves title" do
        expect(subject.data["title"]).to eql("Name")
      end
    end
  end

  context Beams::Sitemap do
    subject { Beams::Sitemap.glob("spec/pages/*") }
    it "has 1 resource" do
      expect(subject.resources.first.request_path).to eql("/spec/pages/test")
    end
  end

  require 'rack/test'
  context Beams::Server do
    include Rack::Test::Methods

    def app
      Beams::Server.glob("spec/pages/*")
    end

    let(:request_path) { "/spec/pages/test" }

    it "gets page" do
      get request_path
      expect(last_response.status).to eql(200)
    end
  end
end
