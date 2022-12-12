require "yaml"
require "date"

module Sitepress
  module Parsers
    # Parses metadata from the header of the page.
    class Frontmatter < Base
      # Default classes that we'll allow YAML to parse. Ideally this doesn't
      # get too huge and we let users control it by setting
      # `Sitepress::Parsers::Frontmatter.permitted_classes = [Whatever, SuperDanger]`
      PERMITTED_CLASSES = [
        Date, # Lots of blogs parse date front matter, so let this fly.
        Time
      ]

      DELIMITER = "---".freeze
      NEWLINE = /\r\n?|\n/.freeze
      PATTERN = /\A(#{DELIMITER}#{NEWLINE}(.+?)#{NEWLINE}#{DELIMITER}#{NEWLINE}*)?(.+)\Z/m

      def initialize(content)
        _, @data, @body = content.match(PATTERN).captures
      end

      def data
        @data ? load_yaml(@data) : {}
      end

      def load_yaml(data)
        if YAML.respond_to? :safe_load
          YAML.safe_load data, permitted_classes: self.class.permitted_classes
        else
          # Live dangerously, lol
          YAML.load data
        end
      end

      def render
        [
          YAML.safe_dump(data),
          DELIMITER,
          $/,
          $/,
          body
        ].join
      end

      class << self
        attr_writer :permitted_classes

        def permitted_classes
          @permitted_classes ||= PERMITTED_CLASSES
        end
      end
    end
  end
end
