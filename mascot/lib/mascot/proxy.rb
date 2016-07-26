module Mascot
  # Manipulate resources after they're requested.
  class Proxy
    def initialize
      @rules = []
    end

    def single_resource(&rule)
      all_resources { |resources| resources.each(&rule) }
    end

    def all_resources(&rule)
      @rules.push rule
    end

    def process(resources)
      @rules.each{ |rule| rule.call resources }
      resources
    end
  end
end
