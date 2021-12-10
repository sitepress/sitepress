module ActionDispatch::Routing
  # I have no idea how or why this works this way, I lifted the pattern from Devise, which came with even
  # more weird stuff. Rails could use an API for adding route helpers to decrease the brittleness of this
  # approach. For now, deal with this helper.
  class Mapper
    DEFAULT_CONTROLLER = "sitepress/site".freeze
    DEFAULT_ACTION = "show".freeze
    ROUTE_GLOB_KEY = "/*resource_path".freeze

    def sitepress_pages(site: Sitepress.site, controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION, root: true)
      constraint = Sitepress::RouteConstraint.new(site: site)

      get ROUTE_GLOB_KEY,
        controller: controller,
        action: action,
        as: :page,
        format: false,
        constraints: constraint

      root controller: controller, action: action if root
    end
  end
end
