require "sitepress-core"

module Sitepress
  autoload :ControllerCompiler,       "sitepress/controller_compiler"
  autoload :RailsConfiguration,       "sitepress/rails_configuration"
  autoload :RouteConstraint,          "sitepress/route_constraint"
  autoload :Server,                   "sitepress/server"
  autoload :ServerCompiler,           "sitepress/server_compiler"

  # Contains singletons for rails and some configuration data.
  Configuration = Struct.new(:site, :routes, :parent_engine)

  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  # Make site available via Sitepress.site from Rails app.
  def self.site
    configuration.site
  end

  # Default configuration object for Sitepress Rails integration.
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
require "sitepress/engine"
