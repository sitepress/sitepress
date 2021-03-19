require "spec_helper"

context Sitepress::NotionMatter do
  subject { Sitepress::NotionMatter.new File.read path }
  let(:path) { "spec/sites/notion/page-with-metadata.md" }

  context "con metadata" do
    it "parses data" do
      expect(subject.data).to eql({
        "Title" => "Fantastic Mr Fox",
        "Appetite" => "Super hungry!",
        "Description" => "Do something amazing: like super amazing.",
        "Sponsors" => "Brad",
        "Stage" => "Implementing",
        "Status" => "💚 On Track",
        "Related" => "../The%20lanes%209ba797dad4c84b86be53f474f50c286b/Land%202fa21cb06ece46d687f51805661e0cfa.md"
      })
    end
    it "parses body" do
      expect(subject.body).to include("3. Eat cheese")
    end
  end
  context "sin metadata" do # That's Spanish for pages that don't have Frontmatter.
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
end
