class SiteController < ApplicationController
  DEFAULT_SITE_LAYOUT = "layouts/layout".freeze

  # Control whether or not to display friendly error reporting messages
  # in Sitepress. The development server turns this on an handles exception,
  # while the compile and other environments would likely have this disabled.
  class_attribute :enable_sitepress_error_reporting, default: false

  # When in a development environment, we'll want to reload the site between
  # requests so we can see the latest changes; otherwise, load the site once
  # and we're done.
  class_attribute :enable_site_reloading, default: false

  # This `rescue_from` order is important; it must come before the
  # `include Sitepress::SitePages` statement; otherwise exceptions
  # won't be properly handled.
  rescue_from Exception, with: :sitepress_error

  include Sitepress::SitePages

  layout :site_layout

  private
  def site_layout
    DEFAULT_SITE_LAYOUT if template_exists? DEFAULT_SITE_LAYOUT
  end

  def sitepress_error(exception)
    raise exception unless has_error_reporting_enabled?

    @title = "Sitepress error in #{current_page.asset.path}".html_safe
    @exception = exception
    render "error", layout: "sitepress", status: :internal_server_error
  end

  def page_not_found(exception)
    raise exception unless has_error_reporting_enabled?

    @title = "Sitepress page #{params[:resource_path].inspect} not found"
    render "page_not_found", layout: "sitepress", status: :not_found
  end

  def has_error_reporting_enabled?
    self.class.enable_sitepress_error_reporting
  end

  def reload_site?
    self.class.enable_site_reloading
  end
end
