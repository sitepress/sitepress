module Mascot
  # Route constraint for rails routes.rb file.
  class RouteConstraint
    def initialize(root: Mascot.configuration.root)
      @root = root
    end

    def matches?(request)
      !!@root.get(request.path)
    end
  end
end
