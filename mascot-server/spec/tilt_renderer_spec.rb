describe Mascot::TiltRenderer do
  let(:resource) { Mascot::Resource.new(asset: asset, request_path: asset.to_request_path) }
  subject { Mascot::TiltRenderer.new(asset) }

  context "rendering" do
    let(:asset) { Mascot::Asset.new(path: "spec/pages/test.html.haml") }
    it "renders" do
      expect(subject.render(locals: {resource: resource})).to include("<h1>")
    end
  end

  context "layout rendering" do
    let(:asset) { Mascot::Asset.new(path: "spec/pages/test_layout.html.erb") }
    it "renders" do
      expect(subject.render(locals: {resource: resource}){ "Hello from within a block" }).to include("Hello from within a block")
    end
  end
end
