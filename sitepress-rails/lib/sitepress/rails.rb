require "sitepress-core"

module Sitepress
  autoload :Compiler,                 "sitepress/compiler"
  autoload :Compilers,                "sitepress/compilers"
  autoload :Model,                    "sitepress/model"
  module Models
    autoload :Collection,             "sitepress/models/collection"
  end
  autoload :RailsConfiguration,       "sitepress/rails_configuration"
  autoload :Sites,                    "sitepress/sites"
  module Renderers
    autoload :Controller,             "sitepress/renderers/controller"
    autoload :Server,                 "sitepress/renderers/server"
  end
  autoload :RouteConstraint,          "sitepress/route_constraint"
  module BuildPaths
    autoload :RootPath,               "sitepress/build_paths/root_path"
    autoload :IndexPath,              "sitepress/build_paths/index_path"
    autoload :DirectoryIndexPath,     "sitepress/build_paths/directory_index_path"
  end

  # Base class for errors if Sitepress can't find a resource, model, etc.
  NotFoundError = Class.new(StandardError)

  # Rescued by ActionController to display page not found error.
  ResourceNotFoundError = Class.new(NotFoundError)
  # Accidentally left out `Error` in the constant name, so I'm setting
  # that up here for backwards compatability.
  ResourceNotFound = ResourceNotFoundError

  # Raised when any of the Render subclasses can't render a page.
  RenderingError = Class.new(RuntimeError)

  # The configured default site (single-site case). For multi-site
  # apps, additional sites live in `Sitepress.sites`.
  def self.site
    configuration.site
  end

  # Registry of additional `Sitepress::Site` instances for multi-site
  # apps. See `Sitepress::Sites` for the full API; the common usage is:
  #
  #   # config/initializers/sitepress.rb
  #   Sitepress.sites << Sitepress::Site.new(root_path: "app/content/admin_docs")
  #
  #   # somewhere later (e.g. a controller class body)
  #   Sitepress.sites.fetch("app/content/admin_docs")
  def self.sites
    configuration.sites
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
