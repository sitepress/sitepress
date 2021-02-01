require "sitepress/version"

module Sitepress
  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "sitepress/asset"
  autoload :Formats,              "sitepress/formats"
  autoload :Frontmatter,          "sitepress/frontmatter"
  autoload :Node,                 "sitepress/node"
  autoload :Path,                 "sitepress/path"
  autoload :Resource,             "sitepress/resource"
  autoload :ResourceCollection,   "sitepress/resource_collection"
  autoload :ResourcesPipeline,    "sitepress/resources_pipeline"
  autoload :Site,                 "sitepress/site"
  autoload :SourceNodeMapper,     "sitepress/source_node_mapper"
  module Middleware
    autoload :RequestCache,       "sitepress/middleware/request_cache"
  end
end
