module ActionDispatch::Routing
  # I have no idea how or why this works this way, I lifted the pattern from Devise, which came with even
  # more weird stuff. Rails could use an API for adding route helpers to decrease the brittleness of this
  # approach. For now, deal with this helper.
  class Mapper
    DEFAULT_CONTROLLER = "sitepress/site".freeze
    DEFAULT_ACTION = "show".freeze
    ROUTE_GLOB_KEY = "/*resource_path".freeze

    # Hook up all the Sitepress pages
    def sitepress_pages(controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION, root: false, site:, kontroller: nil)
      get ROUTE_GLOB_KEY,
        controller: controller,
        action: action,
        as: :page,
        format: false,
        constraints: Sitepress::RouteConstraint.new(site: site)

      sitepress_root controller: controller, action: action if root
    end

    # Hook sitepress root up to the index of rails.
    def sitepress_root(controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION)
      if has_named_route? :root
        Rails.logger.warn "Sitepress tried to configured the 'root' route, but it was already defined. Check the 'routes.rb' file for a 'root' route or call 'sitepress_pages(root: false)'."
      else
        root controller: controller, action: action
      end
    end
  end
end
