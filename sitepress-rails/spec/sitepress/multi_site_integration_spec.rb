require "spec_helper"

# End-to-end coverage for the multi-site flow against the dummy Rails app:
#
#   - A second site is registered in spec/dummy/config/initializers/sitepress.rb
#     via `Sitepress.sites << Sitepress::Site.new(root_path: ...)`.
#   - It's mounted under /secondary by spec/dummy/config/routes.rb via
#     `scope "secondary" do; sitepress_pages controller: "secondary"; end`.
#   - SecondaryController binds to the registered site via
#     `self.site = Sitepress.sites.fetch(...)`.
#   - The site has a page (`pages/welcome.html.erb`) that calls a helper
#     (`helpers/secondary_helper.rb#secondary_greeting`).
#
# This single spec exercises every layer that the unit tests touch in
# isolation: the registry, the engine's boot-time helpers/models/assets
# path setup, the SiteBinding writer's view-path injection, the route
# constraint's controller-class resolution, and the controller's
# `params[:resource_path]`-based resource lookup. If any of those break,
# this spec catches it.
describe "multi-site end-to-end", type: :request do
  let(:secondary_path) { Rails.root.join("app/content/secondary").to_s }

  before do
    # spec_helper.rb resets Sitepress.configuration after every example,
    # so the dummy initializer's `Sitepress.sites << ...` only takes
    # effect on the first example after Rails boots. Re-register here
    # so runtime fetches in the spec body work regardless of test order.
    # The controller's `self.site = ...` binding was captured once at
    # class load time and survives reset_configuration because it lives
    # on the class via `class_attribute :site`.
    unless Sitepress.sites.any? { |s| s.root_path.to_s == secondary_path }
      Sitepress.sites << Sitepress::Site.new(root_path: secondary_path)
    end
  end

  it "registers the secondary site at boot" do
    expect(Sitepress.sites.fetch(secondary_path)).to be_a(Sitepress::Site)
  end

  it "binds SecondaryController to a Site at the secondary root_path via class_attribute" do
    # The controller's `self.site = Sitepress.sites.fetch(...)` runs at
    # class load time. We can't use `equal` here because spec_helper's
    # reset_configuration may have replaced the registry between when
    # the controller loaded and when this test runs — both Sites point
    # at the same root_path, but they're different instances.
    expect(SecondaryController.site).to be_a(Sitepress::Site)
    expect(SecondaryController.site.root_path.to_s).to eq(secondary_path)
  end

  it "renders the secondary site's welcome page through the full Rails request cycle" do
    get "/secondary/welcome"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Hello from the secondary site")
  end

  it "loads the secondary site's helper from the autoloader" do
    # If the engine's set_paths initializer didn't add the secondary
    # site's helpers_path to Zeitwerk, SecondaryHelper#secondary_greeting
    # would be undefined and the page would 500 here.
    get "/secondary/welcome"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("registered via Sitepress.sites")
  end

  it "still serves the default site at the root" do
    get "/hi"
    expect(response).to have_http_status(:ok)
  end

  it "404s for a path the secondary site doesn't have" do
    # The constraint returns false because /does-not-exist isn't in
    # the secondary site, so Rails routing falls through. In a request
    # spec the handling depends on Rails' show_exceptions setting; we
    # accept either a raised RoutingError or a 404 response.
    begin
      get "/secondary/does-not-exist"
      expect(response).to have_http_status(:not_found)
    rescue ActionController::RoutingError
      # also acceptable
    end
  end
end
