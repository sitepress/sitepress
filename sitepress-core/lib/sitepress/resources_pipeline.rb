require "forwardable"

module Sitepress
  # Processes a collection of resources
  class ResourcesPipeline < Array
    def process(resources)
      each{ |processor| processor.process_resources resources }
    end
  end
end
