require 'action_controller/railtie'
require 'haml-rails'
require 'markdown-rails'
require 'sassc'

module Sitepress
  class Server < Rails::Application
    site = Sitepress.configuration.site

    # Boilerplate required to get Rails to boot.
    config.eager_load = true # necessary to silence warning
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    config.secret_key_base = SecureRandom.uuid    # Rails won't start without this

    # Paths unique to Sitepress
    config.root = File.join(File.dirname(__FILE__), "../../app")
    config.paths["app/helpers"].push site.root_path.join("helpers")
    config.paths["app/views"].push site.root_path.expand_path
    config.paths["app/views"].push site.pages_path.expand_path

    # Setup routes
    routes.append { root :to => "sitepress/site#show" }
    routes.append { get "*resource_path", controller: "sitepress/site", action: "show", as: :page, format: false }
    # TODO: Remove this requirement for test environment.
    config.hosts << "example.org"
  end
end

# TODO: Move this into `scss-rails` lib.
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
