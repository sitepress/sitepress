module Sitepress
  class SiteController < ActionController::Base
    # Extracted into a module because other controllers may need
    # to be capable of serving Sitepress pages.
    include Sitepress::SitePages

    sitepress root_path: default_root_path
  end
end
