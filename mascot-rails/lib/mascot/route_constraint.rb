module Mascot
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(sitemap)
      @sitemap = sitemap
    end

    def matches?(request)
      !!@sitemap.find_by_request_path(request.path)
    end
  end
end
