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
      if testable? && alternative_exists?
        page = File::basename current_page.request_path
        original_percent = current_page.data.dig("percent")
        side = ab_test(page, {"original" => original_percent.fdiv(100)},
                       {"alternative" => 1 - original_percent.fdiv(100)})

        if side == "alternative"
          engage_alternate
          return render inline: current_page.body,
                  type: current_page.asset.template_extensions.last,
                  layout: current_page.data.fetch("layout", controller_layout),
                  content_type: current_page.mime_type.to_s
        end
      end
      render inline: current_page.body,
        type: current_page.asset.template_extensions.last,
        layout: current_page.data.fetch("layout", controller_layout),
        content_type: current_page.mime_type.to_s
    end

    protected
    def current_page
      @_current_page ||= find_resource
    end

    def current_alternative
      @_current_alternative ||= find_alternative
    end

    def site
      Sitepress.site
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private
    def engage_alternate
      @_current_page = current_alternative
    end

    def testable?
      self.respond_to?(:ab_test) && current_page.data.dig("percent")
    end

    def alternative_exists?
      alt = site.resources.get(alternative_path)
      site.resources.get(alternative_path)
    end

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

    def alternative_path
      "alternatives/#{params[:resource_path]}"
    end

    def find_alternative
      get alternative_path
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
