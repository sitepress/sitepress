module Mascot
  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render(path)
    end

    protected
    def mascot
      Mascot::ActionControllerContext.new(controller: self, sitemap: sitemap)
    end

    def sitemap
      Mascot.sitemap
    end

    def path
      params[:path]
    end

    def page_not_found
      raise ActionController::RoutingError, "No such page: #{path}"
    end
  end
end
