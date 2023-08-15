module Sitepress
  module Configuration
    class RailsPaths
      attr_reader :root_path

      def initialize(root_path:)
        @root_path = Pathname.new(root_path)
      end

      # Location of website pages.
      def pages_path
        @pages_path ||= root_path.join("pages")
      end

      # Location of helper files.
      def helpers_path
        @helpers_path ||= root_path.join("helpers")
      end

      # Location of rails assets
      def assets_path
        @assets_path ||= root_path.join("assets")
      end

      # Location of pages models.
      def models_path
        @models_path ||= root_path.join("models")
      end

      def configure(app)
        app.paths["app/helpers"].push helpers_path.expand_path
        app.paths["app/assets"].push assets_path.expand_path
        app.paths["app/views"].push root_path.expand_path
        app.paths["app/views"].push pages_path.expand_path
        app.paths["app/models"].push models_path.expand_path
      end
    end
  end
end