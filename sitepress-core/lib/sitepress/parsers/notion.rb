require "yaml"

module Sitepress
  module Parsers
    # Parses metadata from the header of the page.
    class Notion < Base
      DELIMITER = /\n\n/.freeze
      TITLE_KEY = "Title".freeze
      KEY_DELIMITER = ":".freeze

      def initialize(normalize_keys: false)
        @normalize_keys = normalize_keys
      end

      def parse(source)
        scanner = StringScanner.new(source)
        # Parse title
        scanner.scan(/# (.+)#{DELIMITER}?/)
        title = scanner.captures.first
        # Parse metadata
        raw_data = []
        while scanner.scan(/(.+?)#{KEY_DELIMITER} (.+)\n/)
          raw_data.append scanner.captures
        end
        scanner.scan(/\n/)

        pairs = raw_data.prepend([TITLE_KEY, title])
        pairs = normalize_keys pairs if @normalize_keys

        data = Hash[pairs]
        body = scanner.rest

        ParserResult.new(data: data, body: body)
      end

      private
      # Downcase and underscore key names to match Frontmatter formats.
      # This helps if Notion pages need to work within Frontmatter pages.
      def normalize_keys(pairs)
        pairs.map do |key, value|
          normalized_key = key.to_s.downcase.gsub(/\s/, "_")
          [ normalized_key, value ]
        end
      end
    end
  end
end
