require "mascot"

module Mascot
  # Contains singletons for rails and some configuration data.
  Configuration = Struct.new(:site, :routes, :parent_engine)

  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  autoload :RailsConfiguration,       "mascot/rails_configuration"
  autoload :RouteConstraint,          "mascot/route_constraint"
  module Extensions
    autoload :RailsRequestPaths,      "mascot/extensions/rails_request_paths"
    autoload :PartialsRemover,        "mascot/extensions/partials_remover"
    autoload :IndexRequestPath,       "mascot/extensions/index_request_path"
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
