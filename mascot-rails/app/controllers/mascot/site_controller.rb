module Mascot
  class SiteController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

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
    helper_method :current_page

    def root
      @_root ||= Mascot.configuration.root
    end
    helper_method :root

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private

    # Mascot::PageNotFoundError is handled in the default Mascot::SiteController
    # with an execption that Rails can use to display a 404 error.
    def get_resource(path)
      resource = root.get_resource(path)
      if resource.nil?
        # TODO: Display error in context of Reources class root.
        raise Mascot::PageNotFoundError, "No such page: #{path}"
      else
        resource
      end
    end

    # Default finder of the resource for the current controller context.###
    def find_resource
      get_resource params[:resource_path]
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
