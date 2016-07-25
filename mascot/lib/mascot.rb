require "mascot/version"

module Mascot
  # Raised if a user attempts to access a resource outside of the sitemap path.
  InsecurePathAccessError = Class.new(SecurityError)

  autoload :Frontmatter,  "mascot/frontmatter"
  autoload :Resource,     "mascot/resource"
  autoload :Sitemap,      "mascot/sitemap"
  autoload :Asset,        "mascot/asset"
end
