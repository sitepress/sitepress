module Sitepress
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(site: Sitepress.site)
      @site = site
    end

    def matches?(request)
      !!@site.resources.get(request.path)
    end
  end
end
