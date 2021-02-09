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
      # Set the Sitepress site for the controller.
      # self.site ||= Sitepress.site
      rescue_from Sitepress::PageNotFoundError, with: :page_not_found
      helper Sitepress::Engine.helpers
      helper_method :current_page, :site
    end

    # class_methods do
    #   attr_reader :site

    #   # Configures controller when a `site` is set.
    #   def site=(site)
    #     raise_path_exception rails_path: "app/views", site_path: site.root_path
    #     raise_path_exception rails_path: "app/views", site_path: site.pages_path
    #     raise_path_exception rails_path: "app/helpers", site_path: site.helpers_path
    #     # TODO: What is going on with assets? If you add just app/assets, it expands
    #     # it out into a bunch of directories.
    #     # raise_path_exception rails_path: "app/assets", site_path: site.assets_path.join("images")
    #     # raise_path_exception rails_path: "app/assets", site_path: site.assets_path.join("stylesheets")
    #     @site = site
    #   end

    #   private
    #   # TODO: Move this into an integration class and better explain to the user how they can
    #   # fix the
    #   def raise_path_exception(rails_path:, site_path:)
    #     engine = Rails.application
    #     # Eugh, Rails 5 wants to compare via strings. Rails 6 has a `#paths` option that's cleaner.
    #     site_path = site_path.expand_path.to_s
    #     paths = engine.paths[rails_path].to_a

    #     return if paths.include? site_path

    #     raise "Sitepress path #{site_path.inspect} not present in #{engine.class.inspect}.paths[#{rails_path.inspect}]: #{paths.inspect}"
    #   end
    # end

    def show
      render_page current_page
    end

    protected
    def render_page(page)
      if page.asset.mime_type.media_type == "text"
        render_text_resource page
      else
        render_binary_resource page
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
    def render_text_resource(resource)
      with_sitepress_render_cache do
        render inline: resource.body,
          type: resource.asset.template_extensions.last,
          layout: resource.data.fetch("layout", controller_layout),
          content_type: resource.mime_type.to_s
      end
    end

    def render_binary_resource(resource)
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

    # When development environments disable the cache, we still want to turn it
    # on during rendering so that view doesn't rebuild the site on each call.
    def with_sitepress_render_cache(&block)
      cache_resources = site.cache_resources
      begin
        site.cache_resources = true
        yield
      ensure
        site.cache_resources = cache_resources
        site.clear_resources_cache unless site.cache_resources
      end
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
  end
end
