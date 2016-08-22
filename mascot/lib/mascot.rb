require "mascot/version"

module Mascot
  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,                "mascot/asset"
  autoload :DirectoryCollection,  "mascot/directory_collection"
  autoload :Formats,              "mascot/formats"
  autoload :Frontmatter,          "mascot/frontmatter"
  autoload :Resource,             "mascot/resource"
  autoload :ResourcesPipeline,    "mascot/resources_pipeline"
  autoload :ResourcesNode,        "mascot/resources_node"
  autoload :Site,                 "mascot/site"
end
