module Mascot
  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render mascot.resource
    end

    protected
    def mascot
      @_mascot_context ||= Mascot::ActionControllerContext.new(controller: self,
        sitemap: Mascot.configuration.sitemap)
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end
  end
end
