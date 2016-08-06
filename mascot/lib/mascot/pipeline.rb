require "forwardable"

module Mascot
  # Processes a collection of resources
  class Pipeline < Array
    def process(resources)
      each{ |processor| processor.process_resources resources }
    end
  end
end
