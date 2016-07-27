require "mascot"

module Mascot
  # Contains singletons for rails and some configuration data.
  Configuration = Struct.new(:sitemap, :routes, :parent_engine)

  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  autoload :RouteConstraint,  "mascot/route_constraint"
  autoload :ActionControllerContext, "mascot/action_controller_context"

  # Default configuration object for Mascot Rails integration.
  def self.configuration
    @configuration ||= Configuration.new(
      Sitemap.new(root: Rails.root.join("app/pages")),
      true,
      Rails.application)
  end

  def self.configure(&block)
    block.call configuration
  end
end

# This can't be autoloaded; otherwise Rails won't pick up the engine.
require "mascot/engine"
