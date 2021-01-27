require "spec_helper"

context Sitepress::ResourcesNode do
  let(:asset) { Sitepress::Asset.new(path: "/") }
  let(:root) do
    Sitepress::ResourcesNode.new do |root|
      root.formats.add(ext: ".html", asset: asset)
      root.build_child("app") do |app|
        app.formats.add(ext: ".html", asset: asset)
        app.build_child("is") do |is|
          is.formats.add(ext: ".html", asset: asset)
          is.build_child("good").formats.add(ext: ".html", asset: asset)
          is.build_child("bad") do |bad|
            bad.formats.add(ext: ".html", asset: asset)
            bad.build_child("really").formats.add(ext: ".html", asset: asset)
          end
        end
        app.build_child("boo") do |boo|
          boo.formats.add(ext: ".html", asset: asset)
          boo.build_child("radly").formats.add(ext: ".html", asset: asset)
        end
      end
    end
  end
  let(:routes) { %w[
      /index.html
      /app.html
      /app/is.html
      /app/is/good.html
      /app/is/bad.html
      /app/is/bad/really.html
      /app/boo.html
      /app/boo/radly.html] }
  subject { root.get_node(path) }
  it "is_root" do
    expect(root).to be_root
  end
  it "is_leaf" do
    expect(root.get_node("/app/boo/radly.html")).to be_leaf
  end
  context "/app/is/bad.html" do
    let(:path) { "/app/is/bad.html" }
    it { should have_parents(%w[/app/is.html /app.html /.html]) }
    it { should have_siblings(%w[/app/is/good.html]) }
    it { should have_children(%w[/app/is/bad/really.html]) }
  end
  context "/app.html" do
    let(:path) { "/app.html" }
    it { should have_parents(%w[/.html]) }
    it { should have_siblings([]) }
    it { should have_children(%w[/app/is.html /app/boo.html]) }
  end
  context "/a/b/c.html" do
    let(:routes) { %w[
        /a.html
        /a/b.html
        /a/1.html
        /a/b/c.html] }
    let(:root) do
      Sitepress::ResourcesNode.new do |root|
        root.build_child("a") do |a|
          a.formats.add(ext: ".html", asset: asset)
          a.build_child("1").formats.add(ext: ".html", asset: asset)
          a.build_child("b") do |b|
            b.formats.add(ext: ".html", asset: asset)
            b.build_child("c").formats.add(ext: ".html", asset: asset)
          end
        end
      end
    end
    let(:path) { "/a/b.html" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b.html"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.flatten.map(&:request_path)).to match_array(routes)
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
        expect(root.flatten.map(&:request_path)).to match_array(routes - ["/a/b.html"])
      end
    end
  end
  context "/a/b/c" do
    let(:routes) { %w[
        /a
        /a/b
        /a/1
        /a/b/c] }
    let(:root) do
      Sitepress::ResourcesNode.new do |root|
        root.build_child("a") do |a|
          a.formats.add(ext: "", asset: asset)
          a.build_child("1").formats.add(ext: "", asset: asset)
          a.build_child("b") do |b|
            b.formats.add(ext: "", asset: asset)
            b.build_child("c").formats.add(ext: "", asset: asset)
          end
        end
      end
    end
    let(:path) { "/a/b" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.flatten.map(&:request_path)).to match_array(routes)
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
        expect(root.flatten.map(&:request_path)).to match_array(routes - ["/a/b"])
      end
    end
  end
end
