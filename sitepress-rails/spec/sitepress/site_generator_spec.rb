require "spec_helper"
require "rails/generators"
require "generators/sitepress/site/site_generator"

describe Sitepress::SiteGenerator do
  let(:destination_root) { File.expand_path("../../tmp/generators", __dir__) }
  let(:root_path) { "app/sitepress/admin_docs" }

  def run_generator(args)
    silence_stream($stdout) do
      Sitepress::SiteGenerator.start(args, destination_root: destination_root)
    end
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(File::NULL)
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
    old_stream.close
  end

  before do
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(destination_root)
    run_generator [root_path]
  end

  it "creates the pages directory with an index template" do
    expect(File).to exist(File.join(destination_root, root_path, "pages/index.html.erb"))
  end

  it "creates .keep files for helpers, models, and assets" do
    %w[helpers models assets].each do |dir|
      expect(File).to exist(File.join(destination_root, root_path, dir, ".keep"))
    end
  end

  it "generates a controller bound to the registered site" do
    controller_path = File.join(destination_root, "app/controllers/admin_docs_controller.rb")
    expect(File).to exist(controller_path)
    contents = File.read(controller_path)
    expect(contents).to include("class AdminDocsController < Sitepress::SiteController")
    expect(contents).to include(%(self.site = Sitepress.sites.fetch("app/sitepress/admin_docs")))
  end

  it "registers the site in config/initializers/sitepress.rb" do
    initializer = File.join(destination_root, "config/initializers/sitepress.rb")
    expect(File).to exist(initializer)
    contents = File.read(initializer)
    expect(contents).to include(%(Sitepress.sites << Sitepress::Site.new(root_path: "app/sitepress/admin_docs")))
  end

  context "when run a second time for a different site" do
    before { run_generator ["app/sitepress/marketing"] }

    it "appends to the existing initializer instead of overwriting it" do
      contents = File.read(File.join(destination_root, "config/initializers/sitepress.rb"))
      expect(contents).to include("admin_docs")
      expect(contents).to include("marketing")
    end
  end

  context "with --mount-at" do
    let(:routes_path) { File.join(destination_root, "config/routes.rb") }

    before do
      # First run already happened in the outer `before`. Replace the
      # destination's routes.rb with a stub draw block, then run again
      # with the mount flag against a fresh site path.
      FileUtils.mkdir_p(File.dirname(routes_path))
      File.write(routes_path, <<~ROUTES)
        Rails.application.routes.draw do
          # existing routes
        end
      ROUTES
      run_generator ["app/sitepress/marketing", "--mount-at=/marketing"]
    end

    it "injects a scope block into config/routes.rb" do
      contents = File.read(routes_path)
      expect(contents).to include('scope "marketing" do')
      expect(contents).to include('sitepress_pages controller: "marketing", as: :marketing')
    end

    it "places the scope block inside the draw block" do
      contents = File.read(routes_path)
      # The scope block should appear after `routes.draw do` and before `end`.
      draw_index = contents.index("routes.draw do")
      scope_index = contents.index('scope "marketing"')
      end_index = contents.rindex("end")
      expect(scope_index).to be > draw_index
      expect(scope_index).to be < end_index
    end

    it "strips a leading slash from the mount-at path" do
      # /marketing → "marketing" (Rails treats them equivalently for paths)
      contents = File.read(routes_path)
      expect(contents).to include('scope "marketing" do')
      expect(contents).not_to include('scope "/marketing" do')
    end
  end
end
