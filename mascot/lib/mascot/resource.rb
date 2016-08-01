require "forwardable"
require "observer"

module Mascot
  # Represents the request path of an asset. There may be multiple
  # resources that point to the same asset. Resources are immutable
  # and may be altered by the resource proxy.
  class Resource
    include Observable

    extend Forwardable
    def_delegators :asset, :mime_type

    attr_accessor :request_path, :asset
    attr_writer :body, :data

    def initialize(asset: , request_path: nil)
      self.request_path = request_path || asset.to_request_path
      @asset = asset
    end

    # When #dup or #clone is copied, the Resource
    # collection observer must be removed so there's
    # not duplicate resources.
    def initialize_copy(instance)
      instance.delete_observers
      super instance
    end

    def request_path=(request_path)
      old_request_path = @request_path
      # We freeze the value to ensure users can't modify
      # the request_path string in place (e.g. Resource#request_path.capitalize!)
      # and throw the resource out of sync with the Resources collection.
      @request_path = request_path.dup.freeze
      changed
      notify_observers self, old_request_path
    end

    def inspect
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)} @request_path=#{@request_path.inspect} @asset=#{@asset.inspect}>"
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
