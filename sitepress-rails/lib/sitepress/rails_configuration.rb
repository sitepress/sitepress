module Sitepress
  # Configuration object for rails application.
  class RailsConfiguration
    attr_accessor :routes, :cache_resources
    attr_writer :parent_engine

    # Set defaults.
    def initialize
      self.routes = true
    end

    def parent_engine
      @parent_engine ||= Rails.application
    end
  end
end
