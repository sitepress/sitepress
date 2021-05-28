module Sitepress
  # Serves up Sitepress site pages in a rails application. This is mixed into the
  # Sitepress::SiteController, but may be included into other controllers for static
  # page behavior.
  module SitePages
    # Rails 5 requires a format to be given to the private layout method
    # to return the path to the layout.
    DEFAULT_PAGE_RAILS_FORMATS = [:html].freeze

    # Default root path of resources.
    ROOT_RESOURCE_PATH = "".freeze

    extend ActiveSupport::Concern

    included do
      rescue_from Sitepress::PageNotFoundError, with: :page_not_found
      helper Sitepress::Engine.helpers
      helper_method :current_page, :site
      before_action :append_relative_partial_path, only: :show
      around_action :ensure_site_reload, only: :show
    end

    def show
      render_page current_page
    end

    protected
    def render_page(page)
      if page.renderable?
        render_text_resource page
      else
        send_binary_resource page
      end
    end

    def current_page
      @current_page ||= find_resource
    end

    def site
      Sitepress.site
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private
    def append_relative_partial_path
      append_view_path current_page.asset.path.dirname
    end

    def render_text_resource(resource)
      render inline: resource.body,
        type: resource.handler,
        layout: resource.data.fetch("layout", controller_layout),
        content_type: resource.mime_type.to_s
    end

    def send_binary_resource(resource)
      send_file resource.asset.path,
        disposition: :inline,
        type: resource.mime_type.to_s
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

    # Default finder of the resource for the current controller context. If the :resource_path
    # isn't present, then its probably the root path so grab that.
    def find_resource
      get params.fetch(:resource_path, ROOT_RESOURCE_PATH)
    end

    # Returns the current layout for the inline Sitepress renderer. This is
    # exposed via some really convoluted private methods inside of the various
    # versions of Rails, so I try my best to hack out the path to the layout below.
    def controller_layout
      private_layout_method = self.method(:_layout)
      layout =
        if Rails.version >= "6"
          private_layout_method.call lookup_context, current_page_rails_formats
        elsif Rails.version >= "5"
          private_layout_method.call current_page_rails_formats
        else
          private_layout_method.call
        end

      if layout.instance_of? String # Rails 4 and 5 return a string from above.
        layout
      elsif layout # Rails 3 and older return an object that gives us a file name
        File.basename(layout.identifier).split('.').first
      else
        # If none of the conditions are met, then no layout was
        # specified, so nil is returned.
        nil
      end
    end

    # Rails 5 requires an extension, like `:html`, to resolve a template. This
    # method returns the intersection of the formats Rails supports from Mime::Types
    # and the current page's node formats. If nothing intersects, HTML is returned
    # as a default.
    def current_page_rails_formats
      extensions = current_page.node.formats.extensions
      supported_extensions = extensions & Mime::EXTENSION_LOOKUP.keys

      if supported_extensions.empty?
        DEFAULT_PAGE_RAILS_FORMATS
      else
        supported_extensions.map?(&:to_sym)
      end
    end

    def ensure_site_reload
      yield
    ensure
      reload_site
    end

    def reload_site
      site.reload! if reload_site?
    end

    def reload_site?
      !Sitepress.configuration.cache_resources
    end
  end
end
