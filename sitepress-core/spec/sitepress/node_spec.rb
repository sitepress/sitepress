require "spec_helper"

context Sitepress::Node do
  let(:asset) { Sitepress::Asset.new(path: "/") }
  let(:root) do
    Sitepress::Node.new default_format: nil, default_name: "default" do |root|
      root.formats.add(format: :html, asset: asset)
      root.add_child("app") do |app|
        app.formats.add(format: :html, asset: asset)
        app.add_child("is") do |is|
          is.formats.add(format: :html, asset: asset)
          is.add_child("good").formats.add(format: :html, asset: asset)
          is.add_child("bad") do |bad|
            bad.formats.add(format: :html, asset: asset)
            bad.add_child("really").formats.add(format: :html, asset: asset)
          end
        end
        app.add_child("boo") do |boo|
          boo.formats.add(format: :html, asset: asset)
          boo.add_child("radly").formats.add(format: :html, asset: asset)
        end
      end
    end
  end
  let(:routes) { %w[
      /default.html
      /app.html
      /app/is.html
      /app/is/good.html
      /app/is/bad.html
      /app/is/bad/really.html
      /app/boo.html
      /app/boo/radly.html] }
  subject { root.get(path)&.node }
  it "is_root" do
    expect(root).to be_root
  end
  it "is_leaf" do
    expect(root.get("/app/boo/radly.html").node).to be_leaf
  end
  context "/default.html" do
    let(:path) { "/default.html" }
    it { is_expected.to be_root }
  end
  context "/default" do
    let(:path) { "/default" }
    it { is_expected.to be_nil }
  end
  context "/app/is/bad.html" do
    let(:path) { "/app/is/bad.html" }
    it { should have_parents(%w[/app/is.html /app.html /default.html]) }
    it { should have_siblings(%w[/app/is/good.html /app/is/bad.html]) }
    it { should have_children(%w[/app/is/bad/really.html]) }
  end
  context "/app.html" do
    let(:path) { "/app.html" }
    it { should have_parents(%w[/default.html]) }
    it { should have_siblings(%w[/app.html]) }
    it { should have_children(%w[/app/is.html /app/boo.html]) }
  end
  context "/a/b/c.html" do
    let(:routes) { %w[
        /index.html
        /a.html
        /a/b.html
        /a/1.html
        /a/b/c.html] }
    let(:root) do
      Sitepress::Node.new default_format: nil, default_name: nil do |root|
        root.add_child("index") do |index|
          index.formats.add(format: :html, asset: asset)
        end
        root.add_child("a") do |a|
          a.formats.add(format: :html, asset: asset)
          a.add_child("1").formats.add(format: :html, asset: asset)
          a.add_child("b") do |b|
            b.formats.add(format: :html, asset: asset)
            b.add_child("c").formats.add(format: :html, asset: asset)
          end
        end
      end
    end
    context "/index.html" do
      let(:path) { "/index.html" }
      it "has resource" do
        expect(subject.formats.map(&:request_path)).to eql(["/index.html"])
      end
      it { should have_parents([]) }
      it { should have_siblings(%w[/index.html /a.html]) }
      it { should have_children([]) }
    end
    context "/a/b.html" do
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
      it { should have_siblings(%w[/a/1.html /a/b.html]) }
      it { should have_children(%w[/a/b/c.html]) }
      context "remove c.html" do
        before { subject.get("c.html").node.remove }
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
  end
  context "/a/b/c" do
    let(:routes) { %w[
        /a
        /a/b.xml
        /a/b
        /a/1
        /a/b/c] }
    let(:root) do
      Sitepress::Node.new do |root|
        root.add_child("a") do |a|
          a.formats.add(asset: asset)
          a.add_child("1").formats.add(asset: asset)
          a.add_child("b") do |b|
            b.formats.add(format: :xml, asset: asset)
            b.formats.add(format: :html, asset: asset)
            b.add_child("c").formats.add(asset: asset)
          end
        end
      end
    end
    let(:path) { "/a/b" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(%w[/a/b.xml /a/b])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.flatten.map(&:request_path)).to match_array(routes)
      end
    end
    it { should have_parents(["/a"]) }
    it { should have_siblings(%w[/a/1 /a/b.xml /a/b]) }
    it { should have_children(%w[/a/b/c]) }
    context "remove c" do
      before { subject.get("c").node.remove }
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
        expect(root.flatten.map(&:request_path)).to match_array(routes - %w[/a/b /a/b.xml])
      end
    end
    context "/a/b/index.html" do
      it "is the same as /a/b.html" do
        expect(subject.add_child("index")).to eql subject
      end
    end
    context "/a/b" do
      it "raises Sitepress::ExistingRequestPathError if adding default format" do
        expect{subject.formats.add(asset: asset)}.to raise_error(Sitepress::ExistingRequestPathError)
      end
      it "raises Sitepress::ExistingRequestPathError if adding duplicate format" do
        expect{subject.formats.add(asset: asset, format: :html)}.to raise_error(Sitepress::ExistingRequestPathError)
      end
    end
    context "/a/b.html" do
      let(:path) { "/a/b.html" }
      it "gets the same resource as /a/b" do
        expect(subject).to eql root.get("/a/b").node
      end
    end
  end
end
