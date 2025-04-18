require "cgi"

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
      rescue_from Sitepress::ResourceNotFound, with: :resource_not_found
      helper Sitepress::Engine.helpers
      helper_method :current_page, :site
      around_action :ensure_site_reload
    end

    # Public method that is primarily called by Rails to display the page. This should
    # be hooked up to the Rails routes file.
    def show
      render_resource requested_resource
    end

    protected

    # If a resource has a handler, (e.g. erb, haml, etc.) we say its "renderable" and
    # process it. If it doesn't have a handler, we treat it like its just a plain ol'
    # file and serve it up.
    def render_resource(resource)
      if resource.renderable?
        # Set this as our "top-level" resource. We might change it again in the pre-render
        # method to deal with rendering resources inside of resources.
        @current_resource = resource
        render_resource_with_handler resource
      else
        send_binary_resource resource
      end
    end

    # If a resource has a handler (e.g. erb, haml, etc.) we use the Rails renderer to
    # process templates, layouts, partials, etc. To keep the whole rendering process
    # contained in a way that the end user can override, we coupled the resource, source
    # and output within a `Rendition` object so that it may be processed via hooks.
    def render_resource_with_handler(resource)
      render resource, layout: resource_layout(resource)
    end

    # A reference to the current resource that's being requested.
    attr_reader :current_resource

    # In templates resources are more naturally thought of as pages, so we call it `current_page` from
    # there and from the controller.
    alias :current_page :current_resource

    # References the singleton Site from the Sitepress::Configuration object. If you try to make this a class
    # variable and let Rails have multiple Sitepress sites, you might run into issues with respect to the asset
    # pipeline and various path configurations. To make this possible, a new object should be introduced to
    # Sitepress that manages a many-sites to one-rails instance so there's no path issues.
    def site
      Sitepress.site
    end

    # Raises a routing error for Rails to deal with in a more "standard" way if the user doesn't
    # override this method.
    def resource_not_found(e)
      raise ActionController::RoutingError, e.message
    end

    private
    # This makes it possible to render partials from the current resource with relative
    # paths. Without this the paths would have to be absolute.
    def append_relative_partial_path(resource)
      append_view_path resource.asset.path.dirname
    end

    def send_binary_resource(resource)
      send_file resource.asset.path,
        disposition: :inline,
        type: resource.mime_type.to_s
    end

    # Sitepress::ResourceNotFound is handled in the default Sitepress::SiteController
    # with an exception that Rails can use to display a 404 error.
    def get(path)
      resource = site.resources.get(path)
      if resource.nil?
        raise Sitepress::ResourceNotFound, "No such page: #{path}"
      else
        Rails.logger.info "Sitepress resolved asset #{resource.asset.path}"
        resource
      end
    end

    # Default finder of the resource for the current controller context. If the :resource_path
    # isn't present, then its probably the root path so grab that.
    def requested_resource
      get resource_request_path
    end

    # Returns the path of the resource in a way thats properly escape.
    def resource_request_path
      CGI.unescape request.path
    end

    # Returns the current layout for the inline Sitepress renderer. This is
    # exposed via some really convoluted private methods inside of the various
    # versions of Rails, so I try my best to hack out the path to the layout below.
    def resource_layout(resource)
      resource.data.fetch "layout" do
        case template = find_layout(formats: resource.node.formats)
        when ActionView::Template
          template.virtual_path
        else
          template
        end
      end
    end

    # For whatever reason, Rails can't stablize this API so we need to check
    # the version of Rails to make the right call and stablize it.
    def find_layout(formats:)
      case Rails::VERSION
      when -> (rails_version) { rails_version::MAJOR > 8 || rails_version::MAJOR == 8 && rails_version::MINOR > 1 }
        _layout(lookup_context, formats, lookup_context.prefixes)
      else
        _layout(lookup_context, formats)
      end
    end

    # When in development mode, the site is reloaded and rebuilt between each request so
    # that users can see changes to content and site structure. These rebuilds are unnecessary and
    # slow per-request in a production environment, so they should not be reloaded.
    def ensure_site_reload
      yield
    ensure
      reload_site
    end

    # Drops the website cache so that it's rebuilt when called again.
    def reload_site
      site.reload! if reload_site?
    end

    # Looks at the configuration to see if the site should be reloaded between requests.
    def reload_site?
      !Sitepress.configuration.cache_resources
    end
  end
end
