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
end
