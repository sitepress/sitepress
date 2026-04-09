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

    # Lazy default + view-path injection for the controller's bound site.
    # Prepended onto the including class's singleton so we can call
    # `super` to reach `class_attribute`'s reader/writer instead of
    # replacing them.
    module SiteBinding
      # Falls back to `Sitepress.site` (evaluated lazily — important
      # for test environments that reset configuration between examples)
      # when no controller subclass has explicitly assigned a site.
      def site
        super || Sitepress.site
      end

      # Assigning a site also prepends its view paths to this controller's
      # lookup chain. Multi-site view lookups stay local to the controller
      # that owns them. Idempotent — if the controller class is reloaded
      # in development and `self.site =` runs again, we don't grow the
      # view path list with duplicates.
      def site=(new_site)
        super
        prepend_site_view_path new_site.pages_path
        prepend_site_view_path new_site.root_path
      end

      private

      def prepend_site_view_path(path)
        return unless path.exist?
        expanded = path.expand_path.to_s
        return if view_paths.any? { |vp| vp.to_s == expanded }
        prepend_view_path expanded
      end
    end

    included do
      rescue_from Sitepress::ResourceNotFound, with: :resource_not_found
      helper_method :current_page, :site
      around_action :ensure_site_reload

      # Each controller is bound to one site. The default falls back to
      # `Sitepress.site`; subclasses serving a different site override it
      # the standard Rails way:
      #
      #   class Admin::DocsController < Sitepress::SiteController
      #     self.site = Sitepress.sites.fetch("app/content/admin_docs")
      #   end
      #
      # `class_attribute` gives us a normal class-level reader/writer
      # that's inherited by subclasses, and `Sitepress::RouteConstraint`
      # reads it via `controller_class.site` so routing resolves the
      # right site without instantiating the controller.
      class_attribute :site
      singleton_class.prepend(SiteBinding)
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

    # Returns the path of the resource. Reads `params[:resource_path]` (set by
    # the `*resource_path` glob in `sitepress_pages`), which is already
    # scope-relative — Rails excludes the surrounding `scope`/`namespace`
    # path from glob captures, so a mount at `/admin/docs` serving the
    # request `/admin/docs/getting-started` arrives here as `getting-started`.
    def resource_request_path
      "/" + CGI.unescape(params[:resource_path].to_s)
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
      case method(:_layout).arity
      when 3
        _layout(lookup_context, formats, lookup_context.prefixes)
      when 2
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
