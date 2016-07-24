module Mascot
  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  # Renders a mascot page via the params path via ActionController.
  class ActionControllerContext
    attr_reader :controller, :sitemap

    def initialize(controller: , sitemap: )
      @controller = controller
      @sitemap = sitemap
    end

    # Renders a mascot page, given a path, and accepts parameters like layout
    # and locals if the user wants to provide additional context to the rendering
    # call.
    def render(path, layout: nil, locals: {})
      resource = sitemap.find_by_request_path(path)
      raise Mascot::PageNotFoundError, "No such page: #{path} in #{sitemap.file_path.expand_path}" if resource.nil?

      type = resource.template_extensions.last
      # Users may set the layout from frontmatter.
      layout ||= resource.data.fetch("layout", controller_layout)
      # Bring sitemap method into scope for instance_eval below.
      sitemap = sitemap

      controller.instance_eval do
        # For the `wrap_layout` helper.
        @_mascot_locals = locals.merge(sitemap: sitemap, current_page: resource)
        render inline: resource.body,
          type: type,
          layout: layout,
          locals: @_mascot_locals,
          content_type: resource.mime_type.to_s
      end
    end

    private
    # Returns the current layout for the inline Mascot renderer.
    def controller_layout
      layout = controller.send(:_layout)
      if layout.instance_of? String
        layout
      else
        File.basename(layout.identifier).split('.').first
      end
    end
  end
end
