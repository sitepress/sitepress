module Mascot
  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render
    end

    private
    def mascot
      Mascot::ActionControllerContext.new(self)
    end

    def page_not_found
      raise ActionController::RoutingError, "No such page: #{params[:path]}"
    end
  end
end
