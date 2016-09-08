module Mascot
  # Serves up Mascot site pages in a rails application. This is mixed into the
  # Mascot::SiteController, but may be included into other controllers for static
  # page behavior.
  module SitePages
    extend ActiveSupport::Concern

    included do
      rescue_from Mascot::PageNotFoundError, with: :page_not_found
      helper_method :current_page, :resources
    end

    def show
      render inline: current_page.body,
        type: current_page.asset.template_extensions.last,
        layout: current_page.data.fetch("layout", controller_layout),
        content_type: current_page.mime_type.to_s
    end

    protected
    def current_page
      @_current_page ||= find_resource
    end

    def resources
      @_resources ||= Mascot.site.resources
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private

    # Mascot::PageNotFoundError is handled in the default Mascot::SiteController
    # with an execption that Rails can use to display a 404 error.
    def get(path)
      resource = resources.get(path)
      if resource.nil?
        # TODO: Display error in context of Reources class root.
        raise Mascot::PageNotFoundError, "No such page: #{path}"
      else
        resource
      end
    end

    # Default finder of the resource for the current controller context.###
    def find_resource
      get params[:resource_path]
    end

    # Returns the current layout for the inline Mascot renderer.
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
