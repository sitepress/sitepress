module Sitepress
  # Holds the result of a parser for an asset.
  class ParserResult
    attr_accessor :body, :data

    def initialize(body:, data:)
      @data = data
      @body = body
    end
  end
end
