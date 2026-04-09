module Sitepress
  # Route constraint for the Rails routes file. Two ways to construct it:
  #
  #   - Pass `site:` directly — used by the default `sitepress_pages` route
  #     for the single-site case.
  #
  #   - Pass `controller:` (a string like `"admin/docs"`) — the controller
  #     class is resolved lazily and its class-level `.site` method is called
  #     per request. This is what lets a controller bind itself to a site
  #     via `class_attribute :site` and have routing pick it up:
  #
  #       class Admin::DocsController < Sitepress::SiteController
  #         self.site = Sitepress.sites.fetch("app/content/admin_docs")
  #       end
  #
  # `path_prefix` is the URL prefix the route is mounted under (e.g.
  # `/admin/docs`), stripped from `request.path` before the resource lookup.
  # `sitepress_pages` fills this in from `@scope[:path]` automatically.
  class RouteConstraint
    attr_reader :path_prefix

    def initialize(site: nil, controller: nil, path_prefix: nil)
      @explicit_site = site
      @controller_name = controller
      @path_prefix = path_prefix.presence
    end

    def matches?(request)
      !!site.resources.get(resource_path(request))
    end

    # Resolves the site this constraint guards. If a site was passed in
    # explicitly we use it; otherwise we resolve the controller class and
    # ask it. Resolution is lazy because controllers may not be loaded
    # when routes are drawn.
    def site
      @explicit_site || controller_class.site
    end

    private

    def controller_class
      @controller_class ||= begin
        raise ArgumentError, "Sitepress::RouteConstraint needs site: or controller:" if @controller_name.nil?
        "#{@controller_name}_controller".camelize.constantize
      end
    end

    def resource_path(request)
      path = request.path
      if path_prefix && path.start_with?(path_prefix)
        path = path.delete_prefix(path_prefix)
        path = "/" if path.empty?
      end
      path
    end
  end
end
