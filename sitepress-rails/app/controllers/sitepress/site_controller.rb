module Sitepress
  class SiteController < ActionController::Base
    # Extracted into a module because other controllers may need
    # to be capable of serving Sitepress pages.
    include Sitepress::SitePages

    self.site = Sitepress.site
  end
end
