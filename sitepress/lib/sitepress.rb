require "sitepress-core"

module Sitepress
  # CLI components
  autoload :CLI,              "sitepress/cli"
  autoload :ProjectTemplate,  "sitepress/project_template"
  autoload :REPL,             "sitepress/repl"
  
  # Server components
  autoload :Server,           "sitepress/server"
end