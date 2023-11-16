class SiteController < ApplicationController
  include Sitepress::SitePages

  DEFAULT_SITE_LAYOUT = "layouts/layout".freeze

  # This `rescue_from` order is important; it must come before the
  # `include Sitepress::SitePages` statement; otherwise exceptions
  # won't be properly handled.
  rescue_from Exception, with: :standard_error
  rescue_from ActionView::Template::Error, with: :action_view_template_error
  rescue_from Sitepress::ResourceNotFoundError, with: :page_not_found

  layout :site_layout

  private
  def site_layout
    DEFAULT_SITE_LAYOUT if template_exists? DEFAULT_SITE_LAYOUT
  end

  def standard_error(exception)
    render_exception(template: "standard_error", exception: exception)
  end

  def action_view_template_error(exception)
    render_exception(template: "action_template_error", exception: exception)
  end

  def render_exception(template:, exception:)
    raise exception unless has_error_reporting_enabled?

    @resource = requested_resource
    @title = "Error in resource #{@resource.asset.path}"
    @exception = exception
    render template, layout: "sitepress", status: :internal_server_error, formats: :html
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
    Sitepress::Server.config.enable_site_error_reporting
  end

  def reload_site?
    Sitepress::Server.config.enable_site_reloading
  end
end
