module Mascot
  # Renders a mascot page via the params path via ActionController.
  class ActionControllerContext
    attr_reader :controller, :resources

    def initialize(controller: , resources: )
      @controller = controller
      @resources = resources
    end

    # Renders a mascot page, given a path, and accepts parameters like layout
    # and locals if the user wants to provide additional context to the rendering
    # call.
    def render(resource = find_resource, layout: nil, locals: {})
      # Users may set the layout from frontmatter.
      layout ||= resource.data.fetch("layout", controller_layout)
      type = resource.asset.template_extensions.last
      locals = locals.merge(current_page: resource, resources: resources)

      # @_mascot_locals variable is used by the wrap_template helper.
      controller.instance_variable_set(:@_mascot_locals, locals)
      controller.render inline: resource.body,
        type: type,
        layout: layout,
        locals: locals,
        content_type: resource.mime_type.to_s
    end

    # Mascot::PageNotFoundError is handled in the default Mascot::SiteController
    # with an execption that Rails can use to display a 404 error.
    def get(path)
      resource = resources.get_resource(path)
      if resource.nil?
        # TODO: Display error in context of Reources class root.
        raise Mascot::PageNotFoundError, "No such page: #{path}"
      else
        resource
      end
    end

    # Default finder of the resource for the current controller context.###
    def find_resource
      get controller.params[:resource_path]
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
