module Mascot
  module Extensions
    # Removes files beginning with "_" from the resource collection.
    class IndexRequestPath
      # Name of the file that we'll want to change to a / path
      FILE_NAME = "index.html".freeze

      def initialize(file_name: FILE_NAME)
        @file_name = file_name
      end

      def process_resources(resources)
        resources.each do |r|
          if r.asset.path.basename.to_s.start_with? @file_name
            # TODO: Conslidate this into SafeRoot.
            r.request_path = Pathname.new("/").join(r.request_path).dirname.cleanpath.to_s
          end
        end
      end
    end
  end
end
