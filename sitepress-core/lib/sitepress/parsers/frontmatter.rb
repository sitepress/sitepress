require "yaml"

module Sitepress
  module Parsers
    # Parses metadata from the header of the page.

    # TODO: Redo this to use File readline and pos to
    # perform faster
    class Frontmatter < Base
      DELIMITER = "---".freeze
      NEWLINE = /\r\n?|\n/.freeze
      PATTERN = /\A(#{DELIMITER}#{NEWLINE}(.+?)#{NEWLINE}#{DELIMITER}#{NEWLINE}*)?(.+)\Z/m

      def parse(source)
        _, raw_data, body = source.match(PATTERN).captures
        data = raw_data ? YAML.load(raw_data) : {}
        ParserResult.new(data: data, body: body)
      end
    end
  end
end
