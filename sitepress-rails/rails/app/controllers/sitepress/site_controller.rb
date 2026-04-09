module Sitepress
  class SiteController < ::ApplicationController
    # Extracted into a module because other controllers may need
    # to be capable of serving Sitepress pages. The site binding
    # (`self.site = ...`) and view-path injection live on the
    # `SitePages` concern, so any controller that includes it gets
    # them — not just subclasses of `SiteController`.
    include Sitepress::SitePages
  end
end
