require "yaml"

module Sitepress
  # Parsers parse the data and the body out of an asset. The resulting
  # data is referenced by `Resource#data`, which is `current_page.data`
  # from page templates.
  module Parsers
    autoload :Base,         "sitepress/parsers/base"
    autoload :Frontmatter,  "sitepress/parsers/frontmatter"
    autoload :Notion,       "sitepress/parsers/notion"
  end
end
