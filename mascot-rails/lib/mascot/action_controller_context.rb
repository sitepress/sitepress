module Mascot
  # Rescued by ActionController to display page not found error.
  PageNotFoundError = Class.new(StandardError)

  # Renders a mascot page via the params path via ActionController.
  class ActionControllerContext
    attr_reader :controller, :sitemap

    def initialize(controller: , sitemap: , path_param_key: :path)
      @controller = controller
      @sitemap = sitemap
    end

    # Renders a mascot page, given a path, and accepts parameters like layout
    # and locals if the user wants to provide additional context to the rendering
    # call.
    def render(resource = resource, layout: nil, locals: {})
      # Users may set the layout from frontmatter.
      layout ||= resource.data.fetch("layout", controller_layout)
      type = resource.asset.template_extensions.last
      locals = locals.merge(sitemap: sitemap, current_page: resource)

      # @_mascot_locals variable is used by the wrap_template helper.
      controller.instance_variable_set(:@_mascot_locals, locals)
      controller.render inline: resource.body,
        type: type,
        layout: layout,
        locals: locals,
        content_type: resource.mime_type.to_s
    end

    # Mascot::PageNotFoundError is handled in the default Mascot::SitemapController
    # with an execption that Rails can use to display a 404 error.
    def find_by_request_path(path)
      resource = sitemap.find_by_request_path(path)
      if resource.nil?
        raise Mascot::PageNotFoundError, "No such page: #{path} in #{sitemap.file_path.expand_path}"
      else
        resource
      end
    end

    # Default finder of the resource for the current controller context.###
    def resource
      find_by_request_path controller.params[:path]
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
