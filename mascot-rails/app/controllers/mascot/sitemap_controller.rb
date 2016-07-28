module Mascot
  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render mascot.find_resource
    end

    protected
    def resources
      @_mascot_resources ||= Mascot.configuration.resources
    end

    def mascot
      @_mascot_context ||= Mascot::ActionControllerContext.new(controller: self, resources: resources)
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end
  end
end
