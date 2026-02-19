require "thor"

module Sitepress
  class CLI < Thor
    # Helpers for CLI commands.
    #
    # Include this module in your Thor class to get access
    # to Sitepress configuration, site, and Rails environment.
    #
    # The Sitepress environment is automatically booted before commands
    # run, so you can access site, configuration, etc. immediately.
    #
    # Example:
    #
    #   class Sitepress::Deploy::CLI < Thor
    #     include Sitepress::CLI::CommandHelpers
    #
    #     desc "s3", "Deploy to S3"
    #     def s3
    #       site.resources.each { |r| upload(r) }
    #     end
    #   end
    #
    module CommandHelpers
      # No-op for backwards compatibility.
      # The environment is now automatically booted in CLI.start.
      def initialize!(&block)
        # Environment already booted, but yield to block if given
        app.tap(&block) if block_given?
      end

      # The Sitepress::Server Rails application.
      def app
        Sitepress::Server
      end

      # The Sitepress configuration object.
      def configuration
        Sitepress.configuration
      end

      # The configured Site instance.
      def site
        configuration.site
      end

      # The parent Rails engine (Sitepress::Server or host app).
      def rails
        configuration.parent_engine
      end

      # The Rails logger.
      def logger
        rails.config.logger
      end
    end

    # Backwards compatibility alias
    PluginHelpers = CommandHelpers
  end
end
