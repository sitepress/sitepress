require "csv"

module Sitepress
  module Parsers
    # Parses nothing. The body is returned and the data is blank.
    class CSV
      def parse(source)
        data = ::CSV.parse(source)
        ParserResult.new(data: data, body: source)
      end
    end
  end
end
