require "mascot/version"

module Mascot
  # Raised if a user attempts to access a resource outside of the sitemap path.
  UnsafePathAccessError = Class.new(SecurityError)

  autoload :PathValidator,"mascot/path_validator"
  autoload :Resources,    "mascot/resources"
  autoload :Frontmatter,  "mascot/frontmatter"
  autoload :Resource,     "mascot/resource"
  autoload :Sitemap,      "mascot/sitemap"
  autoload :Asset,        "mascot/asset"
end
