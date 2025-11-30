# frozen_string_literal: true

module Sitepress
  # Detects and loads the appropriate asset pipeline (Propshaft or Sprockets).
  # This allows sitepress to work with whichever asset pipeline is available,
  # without forcing a specific dependency.
  module AssetPipeline
    class << self
      # Returns which asset pipeline is loaded, or nil if none
      # @return [Symbol, nil] :propshaft, :sprockets, or nil
      attr_reader :loaded

      # Attempts to load an asset pipeline in order of preference:
      # 1. Propshaft (modern, recommended)
      # 2. Sprockets (legacy, widely used)
      # 3. None (server will work but without asset fingerprinting)
      def load!
        return @loaded if defined?(@loaded)

        @loaded = try_load_propshaft || try_load_sprockets
      end

      # Returns true if an asset pipeline is available
      def available?
        load!
        !@loaded.nil?
      end

      # Returns true if Propshaft is loaded
      def propshaft?
        load!
        @loaded == :propshaft
      end

      # Returns true if Sprockets is loaded
      def sprockets?
        load!
        @loaded == :sprockets
      end

      private

      def try_load_propshaft
        require "propshaft"
        :propshaft
      rescue LoadError
        nil
      end

      def try_load_sprockets
        require "sprockets/railtie"
        :sprockets
      rescue LoadError
        nil
      end
    end
  end
end
