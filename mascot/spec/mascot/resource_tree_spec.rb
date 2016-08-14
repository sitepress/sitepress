require "spec_helper"

context Mascot::ResourceTree do
  let(:routes) { %w[
      /index.html
      /app.html
      /app/is.html
      /app/is/good.html
      /app/is/bad.html
      /app/is/bad/really.html
      /app/boo.html
      /app/boo/radly.html] }
  let(:root) { Mascot::ResourceTree.new }
  subject { root.get(path) }
  before { routes.each { |r| root.add(r, r) } }
  it "is_root" do
    expect(root).to be_root
  end
  it "is_leaf" do
    expect(root.get("/app/boo/radly.html")).to be_leaf
  end
  context "/app/is/bad.html" do
    let(:path) { "/app/is/bad.html" }
    # TODO: Should the root resource be nil?
    it { should have_parents(["/app/is.html", "/app.html", nil]) }
    it { should have_siblings(%w[/app/is/good.html]) }
    it { should have_children(%w[/app/is/bad/really.html]) }
  end
  context "/app.html" do
    let(:path) { "/app.html" }
    it { should have_parents([nil]) }
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
      expect(subject.resource).to eql("/a/b.html")
    end
    it { should have_parents(["/a.html", nil]) }
    it { should have_siblings(%w[/a/1.html]) }
    it { should have_children(%w[/a/b/c.html]) }
  end
end
