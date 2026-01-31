require "yaml"
require "date"

module Sitepress
  module Parsers
    # Parses metadata from the header of the page.
    class Frontmatter < Base
      class Renderer
        attr_reader :body, :data

        def initialize(body:, data:)
          @body = body
          @data = data
        end

        def dump_yaml(data)
          YAML.safe_dump data, permitted_classes: Frontmatter.permitted_classes
        end

        def render
          [
            dump_yaml(Data.unmanage(data)),
            Frontmatter::DELIMITER,
            $/,
            $/,
            body
          ].join
        end
      end

      # Default classes that we'll allow YAML to parse. Ideally this doesn't
      # get too huge and we let users control it by setting
      # `Sitepress::Parsers::Frontmatter.permitted_classes = [Whatever, SuperDanger]`
      PERMITTED_CLASSES = [
        Date,
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
        YAML.safe_load data, permitted_classes: self.class.permitted_classes
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
