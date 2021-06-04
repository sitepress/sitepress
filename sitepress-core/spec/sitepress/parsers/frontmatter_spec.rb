require "spec_helper"

context Sitepress::Parsers::Frontmatter do
  context "con frontmatter" do
    subject { Sitepress::Parsers::Frontmatter.new File.read "spec/sites/sample/pages/test.html.haml" }
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
  context "sin frontmatter" do # That's Spanish for pages that don't have Parsers::Frontmatter.
    subject { Sitepress::Parsers::Frontmatter.new File.read "spec/sites/sample/pages/sin_frontmatter.html.haml" }
    it "parses data" do
      expect(subject.data).to eql({})
    end
    it "parses body" do
      expect(subject.body).to_not be_nil
    end
  end
  context "confusing frontmatter" do
    subject { Sitepress::Parsers::Frontmatter.new File.read "spec/sites/sample/pages/confusion.html.md" }
    it "parses data" do
      expect(subject.data).to eql({"title" => "Hi there"})
    end
    it "parses body" do
      expect(subject.body).to eql("""Here is a sample Markdown file with Frontmatter

```md
---
cheese: Swiss
---

This is a sample
```

That's all!
""")
    end
  end
end
