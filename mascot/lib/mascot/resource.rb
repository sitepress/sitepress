require "forwardable"

module Mascot
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset.
  class Resource
    attr_reader :request_path, :asset

    extend Forwardable
    def_delegators :asset, :data, :body, :mime_type

    def initialize(request_path: , asset: )
      @request_path = request_path
      @asset = asset
    end

    def ==(asset)
      request_path == asset.request_path
    end
  end
end
