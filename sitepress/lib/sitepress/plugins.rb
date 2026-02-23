module Sitepress
  # Plugin registry for CLI command extensions.
  #
  # Plugins are discovered via Bundler by looking for gems with
  # `sitepress_plugin: "true"` in their gemspec metadata.
  #
  # Example plugin registration:
  #
  #   Sitepress::Plugins.register(
  #     name: "deploy",
  #     cli: Sitepress::Deploy::CLI,
  #     description: "Deploy your site"
  #   )
  #
  module Plugins
    class << self
      def registry
        @registry ||= {}
      end

      # Register a plugin CLI class.
      #
      # @param name [String] The subcommand name (e.g., "deploy")
      # @param cli [Class] A Thor class with the plugin's commands
      # @param description [String] Description shown in `sitepress help`
      def register(name:, cli:, description: nil)
        name = name.to_s
        if registry.key?(name)
          warn "WARNING: Sitepress plugin '#{name}' is already registered, skipping"
          return
        end

        registry[name] = {
          cli: cli,
          description: description || "#{name} commands"
        }
      end

      # Discover and load plugins from Bundler.
      # Looks for gems with `sitepress_plugin: "true"` metadata.
      def discover!
        return unless defined?(Bundler)

        Bundler.load.specs.each do |spec|
          next unless spec.metadata["sitepress_plugin"] == "true"

          begin
            require spec.name
          rescue LoadError => e
            warn "WARNING: Could not load Sitepress plugin '#{spec.name}': #{e.message}"
          end
        end
      end

      # List of registered plugin names.
      def registered
        registry.keys
      end

      # Get a specific plugin by name.
      def get(name)
        registry[name.to_s]
      end

      # Iterate over all registered plugins.
      def each(&block)
        registry.each(&block)
      end

      # Clear the registry (useful for testing).
      def reset!
        @registry = {}
      end
    end
  end
end
