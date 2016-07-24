module Mascot
  # Parses metadata from the header of the page.
  class Frontmatter
    DELIMITER = "---".freeze
    PATTERN = /\A(#{DELIMITER}\n(.+)\n#{DELIMITER}\n)?(.+)\Z/m

    attr_reader :body

    def initialize(content)
      _, @data, @body = content.match(PATTERN).captures
    end

    def data
      @data ? YAML.load(@data) : {}
    end

    private
    def parse
      @content
    end
  end
end
