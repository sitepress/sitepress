class SiteController < ApplicationController
  DEFAULT_SITE_LAYOUT = "layouts/layout".freeze

  # This `rescue_from` order is important; it must come before the
  # `include Sitepress::SitePages` statement; otherwise exceptions
  # won't be properly handled.
  rescue_from Exception, with: :sitepress_error

  include Sitepress::SitePages

  layout :site_layout
  sitepress root_path: "."

  private
  def site_layout
    DEFAULT_SITE_LAYOUT if template_exists? DEFAULT_SITE_LAYOUT
  end

  def sitepress_error(exception)
    @title = "Sitepress error in #{current_page.asset.path}".html_safe
    @exception = exception
    render "error", layout: "sitepress", status: :internal_server_error
  end

  def page_not_found(exception)
    @title = "Sitepress page #{params[:resource_path].inspect} not found"
    render "page_not_found", layout: "sitepress", status: :not_found
  end
end
