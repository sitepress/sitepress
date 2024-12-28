class SiteController < Sitepress::SiteController
  # Override this method to implement your processing logic for Sitepress pages.
  def show
    render_resource current_resource
  end
end
