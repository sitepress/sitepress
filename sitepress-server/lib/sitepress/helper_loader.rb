module Sitepress
  # Loads modules into an isolated namespace that will be
  # used for the rendering context. This loader is designed to
  # be immutable so that it throws away the constants and modules
  # on each load.
  #
  # TODO: Rename this to a RenderingContext, or something.
  class HelperLoader
    def initialize(paths:)
      @paths = Array(paths)
    end

    def context(locals: {})
      modules = helpers
      Object.new.tap do |object|
        # Locals of rendering context that are accessible from the
        # helper modules.
        locals.each do |name, value|
          object.define_singleton_method(name) { value }
        end
        # Include the helper modules of the rendering context.
        modules.constants.each do |module_name|
          object.send(:extend, modules.const_get(module_name))
        end
      end
    end

    private
    def helpers
      Module.new.tap do |m|
        @paths.each do |path|
          m.module_eval File.read(path)
        end
      end
    end
  end
end
