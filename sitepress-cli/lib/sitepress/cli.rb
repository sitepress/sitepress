require "thor"
require_relative "boot"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    include Thor::Actions

    source_root File.expand_path("../../../templates/default", __FILE__)

    option :bind_address, default: PreviewServer::DEFAULT_BIND_ADDRESS, aliases: :a
    option :port, default: PreviewServer::DEFAULT_PORT, aliases: :p, type: :numeric
    desc "server", "Run preview server"
    def server
      Sitepress::Server.initialize!
      PreviewServer.new.run port: options.fetch("port"),
        bind_address: options.fetch("bind_address")
    end

    option :output_path, default: "./build"
    desc "compile", "Compile project into static pages"
    def compile
      Sitepress::Server.initialize!
      Compiler.new(site: Sitepress.site).compile target_path: options.fetch("output_path")
    end

    desc "console", "Interactive project shell"
    def console
      Sitepress::Server.initialize!
      REPL.new(context: Sitepress.configuration).start
    end

    desc "new PATH", "Create new project at PATH"
    def new(target)
      inside target do
        directory self.class.source_root, "."
        run "bundle install"
      end
    end

    desc "version", "Show version"
    def version
      say "Sitepress #{Sitepress::VERSION}"
    end
  end
end
