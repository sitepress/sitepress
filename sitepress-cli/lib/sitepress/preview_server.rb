module Sitepress
  # Evaluates a configuration file on each site request, then delegates to
  # a sitepres server for rednering. In a production environment, you'd want
  # to run `Sitepress::Server` directly.
  class PreviewServer
    def initialize(project:)
      @project = project
    end

    def call(env)
      @project.server.call(env)
    end
  end
end
