module Sitepress
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(site: SiteController.site)
      @site = site
    end

    def matches?(request)
      !!@site.resources.get(request.path)
    end
  end
end
