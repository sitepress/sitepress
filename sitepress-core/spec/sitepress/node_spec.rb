require "spec_helper"

context Sitepress::Node do
  let(:asset) { Sitepress::Asset.new(path: "/") }
  let(:root) do
    Sitepress::Node.new default_format: nil, default_name: "default" do |root|
      root.resources.add_asset(asset, format: :html)
      root.child("app") do |app|
        app.resources.add_asset(asset, format: :html)
        app.child("is") do |is|
          is.resources.add_asset(asset, format: :html)
          is.child("good").resources.add_asset(asset, format: :html)
          is.child("bad") do |bad|
            bad.resources.add_asset(asset, format: :html)
            bad.child("really").resources.add_asset(asset, format: :html)
          end
        end
        app.child("boo") do |boo|
          boo.resources.add_asset(asset, format: :html)
          boo.child("radly").resources.add_asset(asset, format: :html)
        end
      end
      # Let's build up some nodes manually.
      post = Sitepress::Node.new(name: "post", default_format: nil)
      post.resources.add_asset(asset, format: :html)
      blog = Sitepress::Node.new(name: "blog", default_format: nil)
      post.parent = blog
      blog.resources.add_asset(asset, format: :html)
      blog.parent = root
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
      /app/boo/radly.html
      /blog.html
      /blog/post.html
    ] }

  subject { root.get(path)&.node }

  it "is_root" do
    expect(root).to be_root
  end

  it "is_leaf" do
    expect(root.get("/app/boo/radly.html").node).to be_leaf
  end

  it "flattens routes" do
    expect(root.resources.flatten.map(&:request_path)).to match_array(routes)
  end

  context "/default.html" do
    let(:path) { "/default.html" }
    it { is_expected.to be_root }
  end

  context "/default" do
    let(:path) { "/default" }
    it { is_expected.to be_nil }
  end

  context "/blog/post.html" do
    let(:path) { "/blog/post.html" }
    it { should have_parents(%w[/blog.html /default.html]) }
    it { should have_siblings(%w[/blog/post.html]) }
    it { should have_children([]) }
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
    it { should have_siblings(%w[/app.html /blog.html]) }
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
        root.child("index") do |index|
          index.resources.add_asset(asset, format: :html)
        end
        root.child("a") do |a|
          a.resources.add_asset(asset, format: :html)
          a.child("1").resources.add_asset(asset, format: :html)
          a.child("b") do |b|
            b.resources.add_asset(asset, format: :html)
            b.child("c").resources.add_asset(asset, format: :html)
          end
        end
      end
    end

    context "/index.html" do
      let(:path) { "/index.html" }
      it "has resource" do
        expect(subject.resources.map(&:request_path)).to eql(["/index.html"])
      end
      it { should have_parents([]) }
      it { should have_siblings(%w[/index.html /a.html]) }
      it { should have_children([]) }
    end

    context "/a/b.html" do
      let(:path) { "/a/b.html" }
      it "has resource" do
        expect(subject.resources.map(&:request_path)).to eql(["/a/b.html"])
      end
      context "enumerable" do
        it "iterates through resources" do
          expect(root.resources.flatten.map(&:request_path)).to match_array(routes)
        end
      end
      it { should have_parents(["/a.html"]) }
      it { should have_siblings(%w[/a/1.html /a/b.html]) }
      it { should have_children(%w[/a/b/c.html]) }
      describe "#remove" do
        context "remove c.html" do
          before { subject.get("c.html").node.remove }
          it { should have_children([]) }
          it "removes route" do
            expect(root.resources.flatten.map(&:request_path)).to match_array(routes - ["/a/b/c.html"])
          end
        end
        context "remove /a/b.html" do
          before { subject.remove }
          it { should have_parents([]) }
          it { should have_siblings([]) }
          it { should have_children(%w[/c.html]) }
          it "removes route" do
            expect(root.resources.flatten.map(&:request_path)).to match_array(routes - ["/a/b.html", "/a/b/c.html"])
          end
        end
      end
    end

    describe "#parent=" do
      context "/a/b" do
        let(:path) { "/a/b.html" }
        context "set to /a/b/c" do
          let(:c) { root.dig("a", "b", "c") }
          it "can't change parent to a child" do
            expect{subject.parent = c}.to raise_error Sitepress::Error, "Parent node can't be changed to one of its children"
          end
        end
        context "set to /a" do
          # Parent is already "a", so make sure nothing changes.
          let(:a) { root.dig("a") }
          before { subject.parent = a }
          it { should have_parents(["/a.html"]) }
          it { should have_siblings(%w[/a/1.html /a/b.html]) }
          it { should have_children(%w[/a/b/c.html]) }
        end
        context "set nil" do
          before { subject.parent = nil }
          it { should be_root }
          it { should have_parents([]) }
          it { should have_siblings([]) }
          it { should have_children(%w[/c.html]) }
        end
        context "set nil and back to original" do
          before do
            original = subject.parent
            subject.parent = nil
            subject.parent = original
          end
          it { should have_parents(["/a.html"]) }
          it { should have_siblings(%w[/a/1.html /a/b.html]) }
          it { should have_children(%w[/a/b/c.html]) }
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
        root.child("a") do |a|
          a.resources.add_asset(asset)
          a.child("1").resources.add_asset(asset)
          a.child("b") do |b|
            b.resources.add_asset(asset, format: :xml)
            b.resources.add_asset(asset, format: :html)
            b.child("c").resources.add_asset(asset)
          end
        end
      end
    end
    let(:path) { "/a/b" }
    it "has resource" do
      expect(subject.resources.map(&:request_path)).to eql(%w[/a/b.xml /a/b])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.resources.flatten.map(&:request_path)).to match_array(routes)
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
      it { should have_parents([]) }
      it { should have_siblings([]) }
      it { should have_children(%w[/c]) }
      it "removes route" do
        expect(root.resources.flatten.map(&:request_path)).to match_array(routes - %w[/a/b /a/b.xml /a/b /a/b/c])
      end
    end
    context "/a/b/index.html" do
      it "is the same as /a/b.html" do
        expect(subject.child("index")).to eql subject
      end
    end
    context "/a/b" do
      it "raises Sitepress::ExistingRequestPathError if adding default format" do
        expect{subject.resources.add_asset(asset)}.to raise_error(Sitepress::ExistingRequestPathError)
      end
      it "raises Sitepress::ExistingRequestPathError if adding duplicate format" do
        expect{subject.resources.add_asset(asset, format: :html)}.to raise_error(Sitepress::ExistingRequestPathError)
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
