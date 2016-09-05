module Mascot
  class SiteController < ::ApplicationController
    # Extracted into a module because other controllers may need
    # to be capable of serving Mascot pages.
    include Mascot::SitePages
  end
end
