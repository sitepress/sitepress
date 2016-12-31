module Sitepress
  # Serves up Sitepress site pages in a rails application. This is mixed into the
  # Sitepress::SiteController, but may be included into other controllers for static
  # page behavior.
  module SitePages
    extend ActiveSupport::Concern

    included do
      rescue_from Sitepress::PageNotFoundError, with: :page_not_found
      helper Sitepress::Engine.helpers
      helper_method :current_page, :site
    end

    def show
      render_page current_page
    end

    protected
    def render_page(page)
      render inline: page.body,
        type: page.asset.template_extensions.last,
        layout: page.data.fetch("layout", controller_layout),
        content_type: page.mime_type.to_s
    end

    def current_page
      @_current_page ||= find_resource
    end

    def site
      Sitepress.site
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private

    # Sitepress::PageNotFoundError is handled in the default Sitepress::SiteController
    # with an execption that Rails can use to display a 404 error.
    def get(path)
      resource = site.resources.get(path)
      if resource.nil?
        # TODO: Display error in context of Reources class root.
        raise Sitepress::PageNotFoundError, "No such page: #{path}"
      else
        resource
      end
    end

    # Default finder of the resource for the current controller context.###
    def find_resource
      get params[:resource_path]
    end

    # Returns the current layout for the inline Sitepress renderer.
    def controller_layout
      layout = self.send(:_layout)
      if layout.instance_of? String
        layout
      else
        File.basename(layout.identifier).split('.').first
      end
    end
  end
end
