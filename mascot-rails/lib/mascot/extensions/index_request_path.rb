module Mascot
  module Extensions
    # Removes files beginning with "_" from the resource collection.
    class IndexRequestPath
      # Name of the file that we'll want to change to a / path
      FILE_NAME = "index.html".freeze

      def initialize(file_name: FILE_NAME)
        @file_name = file_name
      end

      def process_resources(node)
        node.each do |r|
          asset = r.asset
          if asset.path.basename.to_s.start_with? @file_name
            request_path = Pathname.new("/").join(r.request_path).dirname.cleanpath.to_s
            node.formats.remove(r)
            node.add(path: request_path, asset: asset)
          end
        end
      end
    end
  end
end
