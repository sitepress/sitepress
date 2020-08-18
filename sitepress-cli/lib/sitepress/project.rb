require "pathname"
require "forwardable"

module Sitepress
  # Configures a site server, compiler, etc from a single configuration
  # file. Useful for static sites or anything that's running outside of
  # a framework like Rails.
  class Project
    # Default path of project configuration file.
    DEFAULT_CONFIG_FILE = "site.rb".freeze

    def initialize(config_file: DEFAULT_CONFIG_FILE)
      @config_file = config_file
    end

    def compiler
      Compiler.new(site: site)
    end

    def server
      Server.new(site: site)
    end

    def site
      ConfigurationFile.new(path: @config_file).parse
    end
  end

  # Evaluates a configuration file to configure a site.
  class ConfigurationFile
    Context = Struct.new(:site)

    def initialize(path: Project::DEFAULT_CONFIG_FILE)
      @path = Pathname.new(path)
    end

    def parse(site: Sitepress::Site.new)
      site.tap do |s|
        Context.new(s).instance_eval File.read(@path), @path.to_s
      end
    end
  end
end
