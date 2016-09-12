module Sitepress
  class SiteController < ::ApplicationController
    # Extracted into a module because other controllers may need
    # to be capable of serving Sitepress pages.
    include Sitepress::SitePages
  end
end
