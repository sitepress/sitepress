module Mascot
  PageNotFoundError = Class.new(StandardError)

  class SitemapController < ::ApplicationController
    rescue_from Mascot::PageNotFoundError, with: :page_not_found

    def show
      sitemap = Mascot.sitemap
      resource = sitemap.find_by_request_path(params[:path])

      if resource
        template_type = resource.template_extensions.last
        # Users may set the layout from frontmatter.
        template_layout = resource.data.fetch("layout", current_layout)
        # For the `wrap_layout` helper.
        @_mascot_locals = { sitemap: sitemap, current_page: resource }

        # TODO: This doesn't work properly in rails with content_for blocks. 
        # Figure out why and get chaining to work.
        #
        # # Render for chained extensions on page. For example `blah.html.md.erb`.
        # rendered_body = resource.template_extensions.reduce(resource.body) do |body, extension|
        #   render_to_string inline: body,
        #     type: extension,
        #     locals: @_mascot_locals
        # end

        # render inline: rendered_body,
        #   type: false,
        #   layout: template_layout,
        #   locals: @_mascot_locals,
        #   content_type: resource.mime_type.to_s

        render inline: resource.body,
          type: template_type,
          layout: template_layout,
          locals: @_mascot_locals,
          content_type: resource.mime_type.to_s
      else
        raise Mascot::PageNotFoundError
      end
    end

    private
    def page_not_found
      raise ActionController::RoutingError, "No such page: #{params[:path]}"
    end

    # Returns the current layout for the inline Mascot renderer.
    def current_layout
      layout = self.send(:_layout)
      if layout.instance_of? String
        layout
      else
        File.basename(layout.identifier).split('.').first
      end
    end
  end
end
