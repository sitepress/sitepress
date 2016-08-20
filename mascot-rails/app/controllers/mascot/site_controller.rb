module Mascot
  class SiteController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      mascot.render mascot.find_resource
    end

    protected
    def root
      @_mascot_root ||= Mascot.configuration.root
    end

    def mascot
      @_mascot_context ||= Mascot::ActionControllerContext.new(controller: self, root: root)
    end

    def page_not_found(e)
      raise ActionController::RoutingError, e.message
    end
  end
end
