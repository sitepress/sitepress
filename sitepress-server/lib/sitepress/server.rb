require "action_controller/railtie"
require "sprockets/railtie"
require "sitepress-rails"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure the rails application.
module Sitepress
  class Server < Rails::Application
    # Paths unique to Sitepress
    config.root = File.join(File.dirname(__FILE__), "../../rails")

    # Boilerplate required to get Rails to boot.
    config.eager_load = false # necessary to silence warning
    config.cache_classes = false # reload everything since this is dev env.

    config.secret_key_base = SecureRandom.uuid    # Rails won't start without this

    # Setup routes
    routes.append { sitepress_pages root: true, controller: "site" }

    # A logger without a formatter will crash when Sprockets is enabled.
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)

    # Debug mode disables concatenation and preprocessing of assets.
    # This option may cause significant delays in view rendering with a large
    # number of complex assets.
    config.assets.debug = false

    # Suppress logger output for asset requests.
    config.assets.quiet = true

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = true

    # Allow any host to connect to the development server. The actual binding is
    # controlled by server in the `sitepress-cli`; not by Rails.
    config.hosts << proc { true } if config.respond_to? :hosts

    # Stand-alone boot locations
    paths["config/initializers"] << File.expand_path("./config/initializers")
  end
end

# Load the SassC template handler if SassC is installed as part of this stand-alone server.
require_relative "sass_template_handlers" if defined? SassC::Engine
