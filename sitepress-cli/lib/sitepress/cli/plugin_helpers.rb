require "thor"

module Sitepress
  class CLI < Thor
    # Helpers for CLI plugin commands.
    #
    # Include this module in your plugin's Thor class to get access
    # to Sitepress configuration, site, and Rails environment.
    #
    # Example:
    #
    #   class Sitepress::Deploy::CLI < Thor
    #     include Sitepress::CLI::PluginHelpers
    #
    #     desc "s3", "Deploy to S3"
    #     def s3
    #       initialize!  # Boot Rails/Sitepress
    #       site.resources.each { |r| upload(r) }
    #     end
    #   end
    #
    module PluginHelpers
      # Boot the Rails/Sitepress environment.
      # Call this at the start of commands that need access to the site.
      #
      # @yield [app] Optional block to configure the app before initialization
      def initialize!(&block)
        require File.expand_path("../boot", __dir__)
        app.tap(&block) if block_given?
        app.initialize! unless app.initialized?
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
  end
end
