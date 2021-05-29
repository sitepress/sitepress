module Sitepress
  # Encapsulates the data needed to render a resource from a controller. This
  # lets us keep the functions in the controller more functional, which makes them
  # easier to override by the end users.
  class Rendition
    attr_accessor :resource, :output, :controller_layout

    def initialize(resource)
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
      resource.data.fetch("layout", controller_layout)
    end
  end
end
