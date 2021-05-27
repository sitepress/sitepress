require "spec_helper"

context Sitepress::Path do
  describe "parser" do
    let(:path) { Sitepress::Path.new(string) }
    context "Static HTML file with no handler" do
      let(:string) { "/a/b/c.html" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a b c])
      end
      it "parses format" do
        expect(path.format).to eql(:html)
      end
      it "parses handler" do
        expect(path.handler).to be_nil
      end
      it "parses node_name" do
        expect(path.node_name).to eql("c")
      end
    end
    context "Static HTML file with a dot in filename and no handler" do
      let(:string) { "/a/b/c.tacos.html" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a b c.tacos])
      end
      it "parses format" do
        expect(path.format).to eql(:html)
      end
      it "parses handler" do
        expect(path.handler).to be_nil
      end
      it "parses node_name" do
        expect(path.node_name).to eql("c.tacos")
      end
    end
    context "Dynamic HTML file with ERB handler" do
      let(:string) { "/a/b/c/d.html.erb" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a b c d])
      end
      it "parses format" do
        expect(path.format).to eql(:html)
      end
      it "parses handler" do
        expect(path.handler).to eql(:erb)
      end
      it "parses node_name" do
        expect(path.node_name).to eql("d")
      end
    end
    context "Dynamic HTML file with a dot in filename with ERB handler" do
      let(:string) { "/a/b/c/d.cookies.html.erb" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a b c d.cookies])
      end
      it "parses format" do
        expect(path.format).to eql(:html)
      end
      it "parses handler" do
        expect(path.handler).to eql(:erb)
      end
      it "parses node_name" do
        expect(path.node_name).to eql("d.cookies")
      end
    end
    context "Static file with no extension and no handler" do
      let(:string) { "/a/b/c" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a b c])
      end
      it "parses format" do
        expect(path.format).to be_nil
      end
      it "parses handler" do
        expect(path.handler).to be_nil
      end
      it "parses node_name" do
        expect(path.node_name).to eql("c")
      end
    end
    context "File with no extension and no handler" do
      let(:string) { "a" }
      it "parses node names" do
        expect(path.node_names).to eql(%w[a])
      end
      it "parses format" do
        expect(path.format).to be_nil
      end
      it "parses handler" do
        expect(path.handler).to be_nil
      end
      it "parses node_name" do
        expect(path.node_name).to eql("a")
      end
    end
    context "Root path web request" do
      let(:string) { "/" }
      it "parses node names" do
        expect(path.node_names).to eql([""])
      end
      it "parses format" do
        expect(path.format).to be_nil
      end
      it "parses handler" do
        expect(path.handler).to be_nil
      end
      it "parses node_name" do
        expect(path.node_name).to eql("")
      end
    end
  end
  describe ".handler_extensions" do
    it "has defaults" do
      expect(Sitepress::Path.handler_extensions).to eql(%i[haml erb md markdown])
    end
  end
end
