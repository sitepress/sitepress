require "sitepress/version"

module Sitepress
  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "sitepress/asset"
  autoload :AssetNodeMapper,      "sitepress/asset_node_mapper"
  autoload :AssetPaths,           "sitepress/asset_paths"
  autoload :Data,                 "sitepress/data"
  autoload :Formats,              "sitepress/formats"
  autoload :Node,                 "sitepress/node"
  autoload :Path,                 "sitepress/path"
  autoload :Parsers,              "sitepress/parsers"
  autoload :Resource,             "sitepress/resource"
  autoload :ResourceCollection,   "sitepress/resource_collection"
  autoload :ResourcesPipeline,    "sitepress/resources_pipeline"
  autoload :Site,                 "sitepress/site"
end
