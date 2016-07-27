require "mascot/version"

module Mascot
  # Raised if a user attempts to access a resource outside of the sitemap path.
  UnsafePathAccessError = Class.new(SecurityError)

  autoload :Asset,        "mascot/asset"
  autoload :DiskIndex,    "mascot/disk_index"
  autoload :Frontmatter,  "mascot/frontmatter"
  autoload :MemoryIndex,  "mascot/memory_index"
  autoload :SafeRoot,     "mascot/safe_root"
  autoload :Proxy,        "mascot/proxy"
  autoload :Resources,    "mascot/resources"
  autoload :Resource,     "mascot/resource"
  autoload :Sitemap,      "mascot/sitemap"
end
