# Multi-site registration for the dummy app's integration test.
# Register a "secondary" site rooted at app/content/secondary so the
# end-to-end multi-site spec can hit it through a real Rails request
# cycle.
Sitepress.sites << Sitepress::Site.new(
  root_path: Rails.root.join("app/content/secondary")
)
