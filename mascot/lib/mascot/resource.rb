require "forwardable"

module Mascot
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    attr_accessor :request_path, :asset
    attr_writer :body, :data

    extend Forwardable
    def_delegators :asset, :mime_type

    def initialize(request_path: , asset: )
      @request_path = request_path
      @asset = asset
    end

    def data
      @data ||= asset.data
    end

    def body
      @body ||= asset.body
    end

    def ==(asset)
      request_path == asset.request_path
    end
  end
end
