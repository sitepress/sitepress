# frozen_string_literal: true

require "fileutils"
require "pathname"
require "digest"

module Sitepress
  # Compiles assets for static site generation.
  # Uses the available asset pipeline (Propshaft or Sprockets) for fingerprinting,
  # or falls back to simple file copying if no asset pipeline is available.
  module AssetCompiler
    class << self
      # Compile assets to the target path
      # @param app [Rails::Application] the Rails application
      # @param target_path [String, Pathname] output directory
      # @param logger [Logger] logger for output
      def compile(app:, target_path:, logger: nil)
        target_path = Pathname.new(target_path)
        output_path = target_path.join("assets")

        case AssetPipeline.loaded
        when :propshaft
          compile_with_propshaft(app: app, output_path: output_path, logger: logger)
        when :sprockets
          compile_with_sprockets(app: app, output_path: output_path, logger: logger)
        else
          compile_with_copy(app: app, output_path: output_path, logger: logger)
        end
      end

      private

      def compile_with_propshaft(app:, output_path:, logger:)
        manifest_path = output_path.join(".manifest.json")

        assembly = app.assets
        processor = Propshaft::Processor.new(
          load_path: assembly.load_path,
          output_path: output_path,
          compilers: assembly.compilers,
          manifest_path: manifest_path
        )

        processor.process
      end

      def compile_with_sprockets(app:, output_path:, logger:)
        manifest_path = output_path.join("manifest.json")

        manifest = Sprockets::Manifest.new(app.assets, manifest_path)
        manifest.environment.logger = logger if logger

        # Compile all precompilable assets
        manifest.compile(app.config.assets.precompile)
      end

      def compile_with_copy(app:, output_path:, logger:)
        logger&.warn "No asset pipeline available. Copying assets without fingerprinting."

        FileUtils.mkdir_p(output_path)

        # Copy assets from all configured asset paths
        app.config.assets.paths.each do |source_path|
          source = Pathname.new(source_path)
          next unless source.exist?

          copy_directory(source, output_path)
        end
      end

      def copy_directory(source, dest)
        source.glob("**/*").each do |file|
          next if file.directory?

          relative = file.relative_path_from(source)
          target = dest.join(relative)

          FileUtils.mkdir_p(target.dirname)
          FileUtils.cp(file, target)
        end
      end
    end
  end
end
