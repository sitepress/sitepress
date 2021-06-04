require "yaml"

module Sitepress
  module Parsers
    autoload :Frontmatter,  "sitepress/parsers/frontmatter"
    autoload :Notion,       "sitepress/parsers/notion"
  end
end
