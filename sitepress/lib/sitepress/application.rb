require "action_controller/railtie"
require "propshaft"
require "sitepress-rails"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure the rails application for standalone Sitepress.
# This handles rendering pages via Rails' view layer.
module Sitepress
  class Application < Rails::Application
    # Control whether or not to display friendly error reporting messages
    # in Sitepress. The development server turns this on an handles exception,
    # while the compile and other environments would likely have this disabled.
    config.enable_site_error_reporting = false

    # When in a development environment, we'll want to reload the site between
    # requests so we can see the latest changes; otherwise, load the site once
    # and we're done.
    config.enable_site_reloading = false

    # Default to a development environment type of configuration, which would reload the site.
    # This gets reset later depending on a preference in the `before_initialize` callback.
    config.eager_load = true
    config.cache_classes = true

    config.before_initialize do
      # Eager load classes, content, etc. to boost performance when site reloading is disabled.
      config.eager_load = !config.enable_site_reloading

      # Cache classes for speed in production environments when site reloading is disabled.
      config.cache_classes = !config.enable_site_reloading
    end

    # Path that points the the Sitepress UI rails app; which displays routes, error messages.
    # etc. to the user if `enable_site_error_reporting` is enabled.
    config.root = File.join(File.dirname(__FILE__), "../../rails")

    # Rails won't start without this.
    config.secret_key_base = SecureRandom.uuid

    # Setup routes. The `constraints` key is set to `nil` so the `SiteController` can
    # treat a page not being found as an exception, which it then handles. If the constraint
    # was set to the default, Sitepress would hand off routing back to rails if something isn't
    # found and fail silently.
    routes.append { sitepress_pages root: true, controller: "site", constraints: nil }

    # Setup logger.
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)

    # Allow any host to connect to the development server. The actual binding is
    # controlled by server in the `sitepress-cli`; not by Rails.
    config.hosts << proc { true } if config.respond_to? :hosts

    # Stand-alone boot locations
    paths["config/initializers"] << File.expand_path("./config/initializers")
  end
end
