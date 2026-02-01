require "yaml"

module Sitepress
  module Parsers
    # Parses nothing. The body is returned and the data is blank.
    class Base
      attr_reader :body, :data

      def initialize(source)
        @body = source
        @data = {}
      end

      # Returns the line number where the body starts in the original file.
      # Subclasses should override this if they strip content from the beginning.
      def body_line_offset
        1
      end
    end
  end
end
