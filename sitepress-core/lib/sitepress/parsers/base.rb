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
    end
  end
end
