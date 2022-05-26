class SiteController < ApplicationController
  include Sitepress::SitePages

  DEFAULT_SITE_LAYOUT = "layouts/layout".freeze

  # This `rescue_from` order is important; it must come before the
  # `include Sitepress::SitePages` statement; otherwise exceptions
  # won't be properly handled.
  rescue_from Exception, with: :sitepress_error
  rescue_from Sitepress::ResourceNotFoundError, with: :page_not_found

  layout :site_layout

  private
  def site_layout
    DEFAULT_SITE_LAYOUT if template_exists? DEFAULT_SITE_LAYOUT
  end

  def sitepress_error(exception)
    raise exception unless has_error_reporting_enabled?

    @title = "Error in resource #{current_page.asset.path}".html_safe
    @exception = exception
    render "error", layout: "sitepress", status: :internal_server_error
  end

  def page_not_found(exception)
    raise exception unless has_error_reporting_enabled?
    not_found
  end

  def not_found
    @title = "Could not find resource at #{request.path}"
    render "not_found", layout: "sitepress", status: :not_found
  end

  def has_error_reporting_enabled?
    Sitepress::Server.config.enable_sitepress_error_reporting
  end

  def reload_site?
    Sitepress::Server.config.enable_site_reloading
  end
end
