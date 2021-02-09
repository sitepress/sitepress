require "action_controller/railtie"
require "sprockets/railtie"
require "haml-rails"
require "markdown-rails"
require "sassc"
require "sitepress-rails"

# Configure the rails application.
module Sitepress
  class Server < Rails::Application
    # Paths unique to Sitepress
    config.root = File.join(File.dirname(__FILE__), "../../rails")

    # Boilerplate required to get Rails to boot.
    config.eager_load = false # necessary to silence warning
    config.cache_classes = false # reload everything since this is dev env.
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    config.secret_key_base = SecureRandom.uuid    # Rails won't start without this

    # Setup routes
    routes.append { root to: "site#show" }
    routes.append { get "*resource_path", controller: "site", action: "show", as: :page, format: false }

    # TODO: Remove this requirement for test environment.
    config.hosts << proc { true }

    def self.boot
      # return self if initialized?

      # Setup default configuration for stand-alone Sitepress server. This can be
      # overridden via `config/site.rb`.
      Sitepress.configure do |config|
        config.routes = false
        config.site = Sitepress::Site.new(root_path: ".")
        yield config if block_given?
      end

      initialize!
    end
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
