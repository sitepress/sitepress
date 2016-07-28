module Mascot
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(resources = Mascot.configuration.resources)
      @resources = resources
    end

    def matches?(request)
      !!@resources.get(request.path)
    end
  end
end
