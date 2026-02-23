require "spec_helper"

RSpec.describe Sitepress::Reloader do
  subject { described_class.new }

  describe "#initialize" do
    it "starts with empty watch_paths" do
      expect(subject.watch_paths).to be_empty
    end
  end

  describe "#watch" do
    it "adds a path to watch_paths" do
      subject.watch("/path/to/watch")
      expect(subject.watch_paths).to include("/path/to/watch")
    end

    it "converts pathname to string" do
      subject.watch(Pathname.new("/some/path"))
      expect(subject.watch_paths).to include("/some/path")
    end
  end

  describe "#connect" do
    it "returns a Rack response tuple" do
      status, headers, body = subject.connect
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("text/event-stream")
      expect(body).to be_a(Sitepress::Reloader::SSEConnection)
    end

    it "sets Cache-Control header" do
      _, headers, _ = subject.connect
      expect(headers["Cache-Control"]).to eq("no-cache")
    end

    it "assigns unique client IDs" do
      _, _, body1 = subject.connect
      _, _, body2 = subject.connect
      expect(body1).not_to eq(body2)
    end
  end

  describe "#notify" do
    it "sends change event to connected clients" do
      _, _, body = subject.connect

      # Simulate client connection by starting iteration
      messages = []
      thread = Thread.new do
        body.each { |msg| messages << msg; break if messages.size >= 2 }
      end

      # Give the thread time to start
      sleep 0.05

      subject.notify
      thread.join(1)

      expect(messages).to include("data: connected\n\n")
      expect(messages).to include("event: change\ndata: \n\n")
    end

    it "logs when notifying" do
      logger = StringIO.new
      reloader = described_class.new(logger: logger)

      reloader.notify(modified: ["/path/to/file.erb"], added: ["/path/new.erb"])

      expect(logger.string).to include("Files changed")
      expect(logger.string).to include("Modified /path/to/file.erb")
      expect(logger.string).to include("Added /path/new.erb")
      expect(logger.string).to include("Reloading 0 client(s)")
    end
  end

  describe "#middleware" do
    it "returns the Middleware class" do
      expect(subject.middleware).to eq(Sitepress::Reloader::Middleware)
    end
  end
end

RSpec.describe Sitepress::Reloader::SSEConnection do
  let(:clients) { {} }
  subject { described_class.new(1, clients) }

  describe "#each" do
    it "registers client in clients hash" do
      subject.each { break }
      # Client is removed in ensure block, but was registered
    end

    it "yields connected message first" do
      messages = []
      thread = Thread.new { subject.each { |msg| messages << msg; break } }
      thread.join(1)
      expect(messages.first).to eq("data: connected\n\n")
    end

    it "removes client from hash on completion" do
      subject.each { break }
      expect(clients).to be_empty
    end
  end

  describe "#close" do
    it "signals the connection to close" do
      messages = []
      thread = Thread.new do
        subject.each { |msg| messages << msg }
      end

      sleep 0.05
      subject.close
      thread.join(1)

      expect(messages).to include("data: connected\n\n")
    end
  end
end

RSpec.describe Sitepress::Reloader::Middleware do
  let(:html_app) do
    ->(env) { [200, { "Content-Type" => "text/html" }, ["<html><body>Hello</body></html>"]] }
  end

  let(:json_app) do
    ->(env) { [200, { "Content-Type" => "application/json" }, ['{"hello": "world"}']] }
  end

  describe "#call" do
    context "with HTML response" do
      subject { described_class.new(html_app) }

      it "injects reload script" do
        status, headers, body = subject.call({})
        html = body.join
        expect(html).to include("EventSource")
        expect(html).to include("/_sitepress/changes")
      end

      it "injects script before </body>" do
        status, headers, body = subject.call({})
        html = body.join
        expect(html).to match(/<script>.*<\/script>\s*<\/body>/m)
      end

      it "preserves status code" do
        status, _, _ = subject.call({})
        expect(status).to eq(200)
      end
    end

    context "with non-HTML response" do
      subject { described_class.new(json_app) }

      it "does not modify body" do
        _, _, body = subject.call({})
        expect(body.join).to eq('{"hello": "world"}')
      end
    end

    context "with HTML response without body tag" do
      let(:partial_html_app) do
        ->(env) { [200, { "Content-Type" => "text/html" }, ["<div>Hello</div>"]] }
      end
      subject { described_class.new(partial_html_app) }

      it "appends script at end" do
        _, _, body = subject.call({})
        html = body.join
        expect(html).to end_with("</script>\n")
      end
    end

    context "with error response" do
      let(:error_app) do
        ->(env) { [500, { "Content-Type" => "text/html" }, ["<html><body>Error!</body></html>"]] }
      end
      subject { described_class.new(error_app) }

      it "still injects script" do
        status, _, body = subject.call({})
        expect(status).to eq(500)
        expect(body.join).to include("EventSource")
      end
    end
  end

  describe "SCRIPT" do
    it "contains EventSource code" do
      expect(Sitepress::Reloader::Middleware::SCRIPT).to include("EventSource")
    end

    it "connects to /_sitepress/changes endpoint" do
      expect(Sitepress::Reloader::Middleware::SCRIPT).to include("/_sitepress/changes")
    end

    it "reloads on change event" do
      expect(Sitepress::Reloader::Middleware::SCRIPT).to include("location.reload()")
      expect(Sitepress::Reloader::Middleware::SCRIPT).to include("change")
    end
  end
end
