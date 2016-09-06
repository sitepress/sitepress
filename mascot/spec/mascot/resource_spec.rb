require "spec_helper"

context Mascot::Resource do
  let(:asset_path) { "spec/pages/test.html.haml" }
  let(:asset) { Mascot::Asset.new(path: asset_path) }
  let(:request_path) { asset.to_request_path }
  let(:node) { Mascot::ResourcesNode.new }
  subject { node.add path: "/test.html", asset: asset }

  it "has #mime_type" do
    expect(subject.mime_type.to_s).to eql("text/html")
  end
  it "has #data" do
    expect(subject.data["title"]).to eql("Name")
  end
  it "has #body" do
    expect(subject.body).to include("This is just some content")
  end
  it "has #inspect" do
    expect(subject.inspect).to include(request_path)
  end
  describe "#request_path" do
    it "infers request_path from Asset#to_request_path" do
      expect(subject.request_path).to eql("/test.html")
    end
  end
  describe "resource node relationships" do
    let(:site) { Mascot::Site.new(root_path: "spec/tree") }
    let(:root) { site.root }
    subject{ root.get(path) }
    context "/about.html" do
      let(:path) { "/about.html" }
      it "has no parents" do
        expect(subject.parents).to be_empty
      end
      it "has siblings" do
        expect(subject.siblings).to eql([root.get("/index.html")])
      end
      it "has no children" do
        expect(subject.children).to be_empty
      end
    end
    context "/vehicles/cars/compacts.html" do
      let(:path) { "/vehicles/cars/compacts.html" }
      context "parents" do
        it "has 3 parents", :pending do
          # TODO: Parents should return an array all the way up to root. The user
          # should have to flatten it. This at least gives them the power to count hose
          # far away they are from root.
          expect(subject.parents.map(&:request_path)).to match_array([nil, nil, "/vehicles/cars.html"])
        end
        it "has 1 parents with 2 resources" do
          expect(subject.parents(type: :all).map{ |n| n.map(&:request_path) }).to match_array([[], [], %w[/vehicles/cars.html /vehicles/cars.xml]])
        end
        it "has 1 xml parent when filtered by ext string" do
          expect(subject.parents(type: ".xml").map(&:request_path)).to match_array(%w[/vehicles/cars.xml])
        end
        it "has 1 xml parent when filtered by Mime::Type['xml']" do
          expect(subject.parents(type: MIME::Types.type_for("xml").first).map(&:request_path)).to match_array(%w[/vehicles/cars.xml])
        end
      end
      it "has siblings" do
        expect(subject.siblings.map(&:request_path)).to match_array(%w[/vehicles/cars/cierra.html /vehicles/cars/camry.html])
      end
      it "has children" do
        expect(subject.children.map(&:request_path)).to match_array(%w[/vehicles/cars/compacts/smart.html])
      end
    end
  end
end
