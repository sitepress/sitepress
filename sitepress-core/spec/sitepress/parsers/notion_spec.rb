require "spec_helper"

context Sitepress::Parsers::Notion do
  subject { parser.parse File.read path }
  let(:parser) { Sitepress::Parsers::Notion.new }
  let(:path) { "spec/sites/notion/page-with-metadata.md" }

  context "con metadata" do
    it "parses data" do
      expect(subject.data).to eql({
        "Title" => "Fantastic Mr Fox",
        "Appetite" => "Super hungry!",
        "Description" => "Do something amazing: like super amazing.",
        "Project Sponsors" => "Brad",
        "Stage" => "Implementing",
        "Status" => "💚 On Track",
        "Related" => "../The%20lanes%209ba797dad4c84b86be53f474f50c286b/Land%202fa21cb06ece46d687f51805661e0cfa.md"
      })
    end
    it "parses body" do
      expect(subject.body).to include("3. Eat cheese")
    end
  end
  context "sin metadata" do # That's Spanish for pages that don't have Parsers::Frontmatter.
    let(:path) { "spec/sites/notion/page-without-metadata.md" }
    it "parses data" do
      expect(subject.data).to eql({
        "Title" => "Fantastic Mrs Fox"
      })
    end
    it "parses body" do
      expect(subject.body).to include("3. Eat pickles")
    end
  end
  context "initialized with `normalized_keys: true`" do
    let(:parser) { Sitepress::Parsers::Notion.new(normalize_keys: true) }
    it "normalizes keys" do
      expect(subject.data).to have_key("project_sponsors")
    end
  end
  context "bare page" do
    let(:path) { "spec/sites/notion/bare-page.md" }
    it "parses data" do
      expect(subject.data).to eql({
        "Title" => "<Month> <Day>, <Year>"
      })
    end
    it "parses body" do
      expect(subject.body).to include("")
    end
  end
end
