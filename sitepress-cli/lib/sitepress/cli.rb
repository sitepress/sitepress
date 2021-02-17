require "thor"

module Sitepress
  # Command line interface for compiling Sitepress sites.
  class CLI < Thor
    include Thor::Actions

    source_root File.expand_path("../../../templates/default", __FILE__)

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :bind_address, default: PreviewServer::DEFAULT_BIND_ADDRESS, aliases: :a
    option :port, default: PreviewServer::DEFAULT_PORT, aliases: :p, type: :numeric
    desc "server", "Run preview server"
    def server
      Sitepress::Server.boot
      PreviewServer.new(project: project).run port: options.fetch("port"),
        bind_address: options.fetch("bind_address")
    end

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    option :output_path, default: "./build"
    desc "compile", "Compile project into static pages"
    def compile
      Sitepress::Server.boot
      project.compiler.compile target_path: options.fetch("output_path")
    end

    option :config_file, default: Project::DEFAULT_CONFIG_FILE, aliases: :c
    desc "console", "Interactive project shell"
    def console
      REPL.new(context: project).start
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

    private
    def project
      @_project ||= Sitepress::Project.new config_file: options.fetch("config_file")
    end
  end
end
