require "spec_helper"

context Mascot::Resource do
  let(:asset_path) { "spec/pages/test.html.haml" }
  let(:asset) { Mascot::Asset.new(path: asset_path) }
  let(:request_path) { "/spec/pages/test" }
  subject { Mascot::Resource.new(request_path: request_path, asset: asset) }

  it "has #mime_type" do
    expect(subject.mime_type.to_s).to eql("text/html")
  end
  it "has #data" do
    expect(subject.data["title"]).to eql("Name")
  end
  it "has #body" do
    expect(subject.body).to include("This is just some content")
  end
  it "has #request_path" do
    expect(subject.request_path).to eql("/spec/pages/test")
  end
end
