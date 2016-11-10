require "sitepress-core"

module Sitepress
  # Contains singletons for rails and some configuration data.
  Configuration = Struct.new(:site, :routes, :parent_engine)

  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  autoload :RailsConfiguration,       "sitepress/rails_configuration"
  autoload :RouteConstraint,          "sitepress/route_constraint"
  module Extensions
    autoload :RailsRequestPaths,      "sitepress/extensions/rails_request_paths"
    autoload :PartialsRemover,        "sitepress/extensions/partials_remover"
    autoload :IndexRequestPath,       "sitepress/extensions/index_request_path"
  end

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
