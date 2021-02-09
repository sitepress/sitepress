require "sitepress-core"

module Sitepress
  autoload :Compiler,                 "sitepress/compiler"
  autoload :RailsConfiguration,       "sitepress/rails_configuration"
  autoload :RouteConstraint,          "sitepress/route_constraint"
  module Renderers
    autoload :Controller,             "sitepress/renderers/controller"
    autoload :Server,                 "sitepress/renderers/server"
  end
  module BuildPaths
    autoload :RootPath,               "sitepress/build_paths/root_path"
    autoload :IndexPath,              "sitepress/build_paths/index_path"
    autoload :DirectoryIndexPath,     "sitepress/build_paths/directory_index_path"
  end

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
