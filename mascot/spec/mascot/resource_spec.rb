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
    let(:site) { Mascot::Site.new(root: "spec/tree") }
    let(:resources) { site.resources }
    subject{ resources.get_resource(path) }
    context "/about.html" do
      let(:path) { "/about.html" }
      it "has no parents" do
        expect(subject.parents).to be_empty
      end
      it "has siblings" do
        expect(subject.siblings).to eql([resources.get_resource("/index.html")])
      end
      it "has no children" do
        expect(subject.children).to be_empty
      end
    end
    context "/vehicles/cars/compacts.html" do
      let(:path) { "/vehicles/cars/compacts.html" }
      it "has parents" do
        expect(subject.parents.map(&:request_path)).to match_array(%w[/vehicles/cars.html])
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
