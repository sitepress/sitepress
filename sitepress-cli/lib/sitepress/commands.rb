module Sitepress
  # Command registry for CLI extensions.
  #
  # Commands are discovered via Bundler by looking for gems with
  # `sitepress_command: "true"` in their gemspec metadata.
  #
  # Example command registration:
  #
  #   Sitepress::Commands.register(
  #     name: "deploy",
  #     cli: Sitepress::Deploy::CLI,
  #     description: "Deploy your site"
  #   )
  #
  module Commands
    class << self
      def registry
        @registry ||= {}
      end

      # Register a command CLI class.
      #
      # @param name [String] The subcommand name (e.g., "deploy")
      # @param cli [Class] A Thor class with the commands
      # @param description [String] Description shown in `sitepress help`
      def register(name:, cli:, description: nil)
        name = name.to_s
        if registry.key?(name)
          warn "WARNING: Sitepress command '#{name}' is already registered, skipping"
          return
        end

        registry[name] = {
          cli: cli,
          description: description || "#{name} commands"
        }
      end

      # Discover and load commands from Bundler.
      # Looks for gems with `sitepress_command: "true"` metadata.
      # Also supports deprecated `sitepress_plugin: "true"` for backwards compatibility.
      def discover!
        return unless defined?(Bundler)

        Bundler.load.specs.each do |spec|
          # Support both new and deprecated metadata keys
          is_command = spec.metadata["sitepress_command"] == "true"
          is_legacy_plugin = spec.metadata["sitepress_plugin"] == "true"

          if is_legacy_plugin && !is_command
            warn "DEPRECATION: gem '#{spec.name}' uses sitepress_plugin metadata. " \
                 "Please update to sitepress_command."
          end

          next unless is_command || is_legacy_plugin

          begin
            require spec.name
          rescue LoadError => e
            warn "WARNING: Could not load Sitepress command '#{spec.name}': #{e.message}"
          end
        end
      end

      # List of registered command names.
      def registered
        registry.keys
      end

      # Get a specific command by name.
      def get(name)
        registry[name.to_s]
      end

      # Iterate over all registered commands.
      def each(&block)
        registry.each(&block)
      end

      # Clear the registry (useful for testing).
      def reset!
        @registry = {}
      end
    end
  end

  # Backwards compatibility alias
  Plugins = Commands
end
