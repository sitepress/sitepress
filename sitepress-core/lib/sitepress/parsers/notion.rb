require "yaml"

module Sitepress
  module Parsers
    # Parses metadata from the header of the page.
    class Notion < Base
      DELIMITER = /\n\n/.freeze
      TITLE_KEY = "Title".freeze
      KEY_DELIMITER = ":".freeze

      def initialize(content)
        scanner = StringScanner.new(content)
        # Parse title
        scanner.scan(/# (.+)#{DELIMITER}/)
        @title = scanner.captures.first
        # Parse metadata
        @raw_data = []
        while scanner.scan(/(.+?)#{KEY_DELIMITER} (.+)\n/)
          @raw_data.append scanner.captures
        end
        scanner.scan(/\n/)
        # Parse body
        @body = scanner.rest
      end

      def data
        Hash[@raw_data.prepend([TITLE_KEY, @title])]
      end
    end
  end
end
