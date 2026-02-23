require "sitepress-core"
require "sitepress-server"

module Sitepress
  autoload :Application,        "sitepress/application"
  autoload :ApplicationServer,  "sitepress/application_server"
  autoload :CLI,                "sitepress/cli"
  autoload :Plugins,            "sitepress/plugins"
  autoload :ProjectTemplate,    "sitepress/project_template"
  autoload :REPL,               "sitepress/repl"

  class << self
    # Server is only used in standalone mode
    attr_accessor :server

    # Used by CLI to pass site to RailsConfiguration before Rails is loaded
    attr_accessor :pending_site
  end
end
