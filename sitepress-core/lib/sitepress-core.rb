require "sitepress/version"

module Sitepress
  # Errors raised by Sitepress
  Error = Class.new(StandardError)

  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "sitepress/asset"
  autoload :AssetNodeMapper,      "sitepress/asset_node_mapper"
  autoload :AssetPaths,           "sitepress/asset_paths"
  autoload :Configuration,        "sitepress/configuration"
  autoload :Data,                 "sitepress/data"
  autoload :Node,                 "sitepress/node"
  autoload :Path,                 "sitepress/path"
  autoload :Parsers,              "sitepress/parsers"
  autoload :Resource,             "sitepress/resource"
  autoload :Resources,            "sitepress/resources"
  autoload :ResourceIndexer,      "sitepress/resource_indexer"
  autoload :Site,                 "sitepress/site"
end
