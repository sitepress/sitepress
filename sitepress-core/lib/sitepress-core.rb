require "sitepress/version"

module Sitepress
  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "sitepress/asset"
  autoload :DirectoryCollection,  "sitepress/directory_collection"
  autoload :Formats,              "sitepress/formats"
  autoload :Frontmatter,          "sitepress/frontmatter"
  autoload :Resource,             "sitepress/resource"
  autoload :ResourceCollection,   "sitepress/resource_collection"
  autoload :ResourcesPipeline,    "sitepress/resources_pipeline"
  autoload :ResourcesNode,        "sitepress/resources_node"
  autoload :Site,                 "sitepress/site"
end
