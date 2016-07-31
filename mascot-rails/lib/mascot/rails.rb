require "mascot"

module Mascot
  # Contains singletons for rails and some configuration data.
  Configuration = Struct.new(:sitemap, :routes, :parent_engine)

  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  autoload :ActionControllerContext,  "mascot/action_controller_context"
  autoload :RailsConfiguration,       "mascot/rails_configuration"
  autoload :RouteConstraint,          "mascot/route_constraint"
  module Extensions
    autoload :RailsRequestPaths,      "mascot/extensions/rails_request_paths"
    autoload :PartialsRemover,        "mascot/extensions/partials_remover"
  end

  # Default configuration object for Mascot Rails integration.
  def self.configuration
    @configuration ||= RailsConfiguration.new
  end

  def self.reset_configuration
    @configuration = nil
  end

  def self.configure(&block)
    block.call configuration
  end
end

# This can't be autoloaded; otherwise Rails won't pick up the engine.
require "mascot/engine"
