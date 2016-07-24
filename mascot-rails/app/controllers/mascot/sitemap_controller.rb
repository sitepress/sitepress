module Mascot
  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render params[:path]
    end

    protected
    def mascot
      Mascot::ActionControllerContext.new(controller: self, sitemap: sitemap)
    end

    def sitemap
      Mascot.configuration.sitemap
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end
  end
end
