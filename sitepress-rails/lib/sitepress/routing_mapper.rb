module ActionDispatch::Routing
  # I have no idea how or why this works this way, I lifted the pattern from Devise, which came with even
  # more weird stuff. Rails could use an API for adding route helpers to decrease the brittleness of this
  # approach. For now, deal with this helper.
  class Mapper
    DEFAULT_CONTROLLER = "sitepress/site".freeze
    DEFAULT_ACTION = "show".freeze
    ROUTE_GLOB_KEY = "/*resource_path".freeze

    # Hook up all the Sitepress pages
    def sitepress_pages(controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION, root: false, constraints: Sitepress::RouteConstraint.new, as: :page)
      # Configure the route for Sitepress pages
      get ROUTE_GLOB_KEY,
        format: false,
        action: action,
        controller: controller,
        constraints: constraints
      # Configure the root page
      sitepress_root controller: controller, action: action if root
      # Configure the `page_url` and `page_path` helpers
      sitepress_routes as
    end

    # Hook sitepress root up to the index of rails.
    def sitepress_root(controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION)
      if has_named_route? :root
        Rails.logger.warn "Sitepress tried to configured the 'root' route, but it was already defined. Check the 'routes.rb' file for a 'root' route or call 'sitepress_pages(root: false)'."
      else
        root controller: controller, action: action
      end
    end

    # Setup site helpers that will look for a page first before treating the argument as a path.
    def sitepress_routes(name = :page, controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION)
      @set.named_routes.path_helpers_module.module_eval do
        redefine_method("#{name}_path") do |target, options={}|
          url_for(
            controller:,
            action:,
            resource_path: ActionDispatch::Routing::Mapper.resource_path(target),
            only_path: true,
            **options
          )
      end

      @set.named_routes.url_helpers_module.module_eval do
        redefine_method("#{name}_url") do |target, options={}|
          url_for(
            controller:,
            action:,
            resource_path: ActionDispatch::Routing::Mapper.resource_path(target),
            only_path: false,
            **options
          )
        end
      end
    end

    def self.resource_path(target)
      # Check if it's a Sitepress page and use `request_path`, otherwise treat it as a path string
      case target
      when Sitepress::Resource
        target.path
      when Sitepress::Model
        target.page.path
      when String, Symbol
        Sitepress.site.get(target.to_s).path
      end
    end
  end
end
