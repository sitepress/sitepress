require "sitepress/version"

module Sitepress
  # Errors raised by Sitepress
  Error = Class.new(StandardError)

  # Raised when an asset fails to parse (e.g., invalid YAML frontmatter)
  ParseError = Class.new(Error)

  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "sitepress/page"       # Backwards compatibility
  autoload :AssetNodeMapper,      "sitepress/directory"  # Backwards compatibility
  autoload :AssetPaths,           "sitepress/asset_paths"
  autoload :Directory,            "sitepress/directory"
  autoload :Data,                 "sitepress/data"
  autoload :Image,                "sitepress/image"
  autoload :Node,                 "sitepress/node"
  autoload :Page,                 "sitepress/page"
  autoload :Path,                 "sitepress/path"
  autoload :Parsers,              "sitepress/parsers"
  autoload :Resource,             "sitepress/resource"
  autoload :Resources,            "sitepress/resources"
  autoload :ResourceIndexer,      "sitepress/resource_indexer"
  autoload :ResourcesPipeline,    "sitepress/resources_pipeline"
  autoload :Site,                 "sitepress/site"
  autoload :Static,               "sitepress/static"
end
