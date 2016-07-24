require "spec_helper"

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