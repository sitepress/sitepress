module Mascot
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(sitemap = Mascot.configuration.sitemap)
      @sitemap = sitemap
    end

    def matches?(request)
      !!@sitemap.get(request.path)
    end
  end
end
