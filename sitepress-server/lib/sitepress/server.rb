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
    routes.append { root to: "site#show" }
    routes.append { get "*resource_path", controller: "site", action: "show", as: :page, format: false }

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

    # TODO: Remove this requirement for test environment.
    config.hosts << proc { true }
  end
end

# Configure all other integrations that don't quite work with Rails.
module Sass
  class SassCHandler
    def call(template, source = template.source)
      SassC::Engine.new(source).render.inspect + '.html_safe'
    end
  end

  class SassHandler
    def call(template, source = template.source)
      SassC::Engine.new(SassC::Sass2Scss.convert(source)).render.inspect + '.html_safe'
    end
  end
end

ActionView::Template.register_template_handler :sass, Sass::SassHandler.new
ActionView::Template.register_template_handler :scss, Sass::SassCHandler.new
