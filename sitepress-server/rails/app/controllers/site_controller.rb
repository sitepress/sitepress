class SiteController < ApplicationController
  include Sitepress::SitePages

  DEFAULT_SITE_LAYOUT = "layouts/layout".freeze

  layout :site_layout
  sitepress root_path: "."

  rescue_from Exception, with: :sitepress_rendering_error

  private
  def site_layout
    DEFAULT_SITE_LAYOUT if template_exists? DEFAULT_SITE_LAYOUT
  end

  def sitepress_rendering_error(exception)
    @title = "Sitepress error in #{current_page.asset.path}".html_safe
    @exception = exception
    render "error", layout: "sitepress"
  end
end
