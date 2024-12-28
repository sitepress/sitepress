module Sitepress
  # Encapsulates the data needed to render a resource from a controller. This
  # lets us keep the functions in the controller more functional, which makes them
  # easier to override by the end users.
  class Rendition
    attr_accessor :resource, :output, :layout

    def initialize(resource, layout: nil)
      @resource = resource
    end

    def mime_type
      resource.mime_type.to_s
    end

    def handler
      resource.handler
    end

    def source
      resource.body
    end

    def layout
      resource.data.fetch("layout", @layout)
    end

    def format
      resource.format
    end

    def render_in(view_context)
      view_context.render inline: source, type: handler
    end
  end
end
