module Sitepress
  # Encapsulates the data needed to render a resource from a controller. This
  # lets us keep the functions in the controller more functional, which makes them
  # easier to override by the end users.
  class Rendition
    LAYOUT_FRONTMATTER_KEY = "layout"

    attr_accessor :resource, :output, :layout

    def initialize(resource, layout: false)
      @resource = resource
      @layout = layout
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
  end
end
