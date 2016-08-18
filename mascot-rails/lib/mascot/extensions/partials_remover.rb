module Mascot
  module Extensions
    # Removes files beginning with "_" from the resource collection.
    class PartialsRemover
      # Partial rails prefix.
      PARTIAL_PREFIX = "_".freeze

      def process_resources(resources)
        resources.each do |r|
          r.node.remove if self.class.partial? r.asset.path # Looks like a smiley face, doesn't it?
        end
      end

      def self.partial?(path)
        File.basename(path).starts_with? PARTIAL_PREFIX
      end
    end
  end
end
