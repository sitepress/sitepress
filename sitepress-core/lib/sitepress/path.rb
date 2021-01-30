module Sitepress
  class Path
    DELIMITER = "/".freeze

    attr_reader :node_names, :ext

    def initialize(path, delimiter: DELIMITER)
      @path = path
      @delimiter = delimiter
      parse_path
    end

    def format
      format = @ext.partition(".").last
      return nil if format.nil? or format.empty?
      format.to_sym
    end

    private
      def strip_leading_slash(path)
        path.to_s.gsub(/^\//, "")
      end

      def parse_path
        path, _, file = strip_leading_slash(@path).rpartition(@delimiter)
        @ext = File.extname(file)
        @file = File.basename(file, @ext)
        @node_names = path.split(@delimiter).push(@file)
      end
  end
end
