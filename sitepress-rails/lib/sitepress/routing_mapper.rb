module ActionDispatch::Routing
  # I have no idea how or why this works this way, I lifted the pattern from Devise, which came with even
  # more weird stuff. Rails could use an API for adding route helpers to decrease the brittleness of this
  # approach. For now, deal with this helper.
  class Mapper
    DEFAULT_CONTROLLER = "sitepress/site".freeze
    DEFAULT_ACTION = "show".freeze
    ROUTE_GLOB_KEY = "/*resource_path".freeze

    # Hook up all the Sitepress pages.
    #
    # The mount path is read from the surrounding Rails `scope`/`namespace`,
    # so it never has to be repeated. The site is read from the controller
    # class's `.site` method, so a multi-site app declares the site once on
    # the controller and the routes file just mounts it.
    #
    # @example Default site at the root
    #   sitepress_pages
    #
    # @example A controller-owned site mounted under /admin/docs
    #   # app/controllers/admin/docs_controller.rb
    #   class Admin::DocsController < Sitepress::SiteController
    #     def self.site = Sitepress.site(:admin_docs)
    #   end
    #
    #   # config/routes.rb
    #   namespace :admin do
    #     scope :docs do
    #       sitepress_pages controller: "admin/docs"
    #     end
    #   end
    def sitepress_pages(controller: DEFAULT_CONTROLLER, action: DEFAULT_ACTION, root: false, constraints: nil, as: :page)
      path_prefix = @scope[:path].presence
      constraints ||= Sitepress::RouteConstraint.new(controller: controller, path_prefix: path_prefix)

      get ROUTE_GLOB_KEY,
        controller: controller,
        action: action,
        as: as,
        format: false,
        constraints: constraints

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
