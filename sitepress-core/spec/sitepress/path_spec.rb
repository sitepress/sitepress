require "spec_helper"

context Sitepress::Path do
  let(:string) { "/a/b/c.html" }
  let(:path) { Sitepress::Path.new(string) }
  describe "#node_names" do
    let(:subject) { path.node_names }
    it { is_expected.to eql %w[a b c]}
  end
  describe "#format" do
    let(:subject) { path.format}
    it { is_expected.to eql :html }
  end
end
