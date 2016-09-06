require "spec_helper"

context Mascot::ResourcesNode do
  let(:routes) { %w[
      /index.html
      /app.html
      /app/is.html
      /app/is/good.html
      /app/is/bad.html
      /app/is/bad/really.html
      /app/boo.html
      /app/boo/radly.html] }
  let(:root) { Mascot::ResourcesNode.new }
  subject { root.get_node(path) }
  before { routes.each { |r| root.add(path: r, asset: Mascot::Asset.new(path: r)) } }
  it "is_root" do
    expect(root).to be_root
  end
  it "is_leaf" do
    expect(root.get_node("/app/boo/radly.html")).to be_leaf
  end
  context "/app/is/bad.html" do
    let(:path) { "/app/is/bad.html" }
    # TODO: Should the root resource be nil?
    it { should have_parents(["/app/is.html", "/app.html"]) }
    it { should have_siblings(%w[/app/is/good.html]) }
    it { should have_children(%w[/app/is/bad/really.html]) }
  end
  context "/app.html" do
    let(:path) { "/app.html" }
    it { should have_parents([]) }
    it { should have_siblings(%w[/index.html]) }
    it { should have_children(%w[/app/is.html /app/boo.html]) }
  end
  context "/a/b/c.html" do
    let(:routes) { %w[
        /a.html
        /a/b.html
        /a/1.html
        /a/b/c.html] }
    let(:path) { "/a/b.html" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b.html"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.resources.map(&:request_path)).to match_array(routes)
      end
    end
    it { should have_parents(["/a.html"]) }
    it { should have_siblings(%w[/a/1.html]) }
    it { should have_children(%w[/a/b/c.html]) }
    context "remove c.html" do
      before { subject.get_node("c.html").remove }
      it { should have_children([]) }
    end
    context "remove /a/b.html" do
      before { subject.remove }
      it { should have_parents(["/a.html"]) }
      it { should have_siblings(%w[/a/1.html]) }
      it { should have_children(%w[/a/b/c.html]) }
      it "does not have resource" do
        subject.formats.clear
      end
      it "removes route" do
        expect(root.resources.map(&:request_path)).to match_array(routes - ["/a/b.html"])
      end
    end
  end
  context "/a/b/c" do
    let(:routes) { %w[
        /a
        /a/b
        /a/1
        /a/b/c] }
    let(:path) { "/a/b" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.resources.map(&:request_path)).to match_array(routes)
      end
    end
    it { should have_parents(["/a"]) }
    it { should have_siblings(%w[/a/1]) }
    it { should have_children(%w[/a/b/c]) }
    context "remove c" do
      before { subject.get_node("c").remove }
      it { should have_children([]) }
    end
    context "remove /a/b" do
      before { subject.remove }
      it { should have_parents(["/a"]) }
      it { should have_siblings(%w[/a/1]) }
      it { should have_children(%w[/a/b/c]) }
      it "does not have resource" do
        subject.formats.clear
      end
      it "removes route" do
        expect(root.resources.map(&:request_path)).to match_array(routes - ["/a/b"])
      end
    end
  end
end
