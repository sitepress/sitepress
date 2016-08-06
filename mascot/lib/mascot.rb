require "mascot/version"

module Mascot
  # Raised if a user attempts to access a resource outside of the sitemap path.
  UnsafePathAccessError = Class.new(SecurityError)

  # Raised by Resources if a path is added that's not a valid path.
  InvalidRequestPathError = Class.new(RuntimeError)

  # Raised by Resources if a path is already in its index
  ExistingRequestPathError = Class.new(InvalidRequestPathError)

  autoload :Asset,        "mascot/asset"
  autoload :Frontmatter,  "mascot/frontmatter"
  autoload :ResourcesPipeline,     "mascot/resources_pipeline"
  autoload :Resources,    "mascot/resources"
  autoload :Resource,     "mascot/resource"
  autoload :SafeRoot,     "mascot/safe_root"
  autoload :Sitemap,      "mascot/sitemap"
end
