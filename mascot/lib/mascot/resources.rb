require "forwardable"
require "pathname"

module Mascot
  class Resources
    include Enumerable

    extend Forwardable
    def_delegators :@routes, :size, :empty?, :any?, :clear

    def initialize(root_file_path: )
      @routes = Hash.new
      @root_file_path = Pathname.new(root_file_path)
    end

    def each(&block)
      @routes.values.each(&block)
    end

    def last
      @routes.values.last
    end

    def request_paths
      @routes.keys
    end

    def glob(pattern = "**/**")
      paths = safe_root.glob @root_file_path.join(pattern)
      select { |r| paths.include? r.asset.path.to_s}
    end

    def get(request_path)
      return if request_path.nil?
      @routes[key(request_path)]
    end

    def add(resource)
      validate_request_path resource
      validate_uniqueness resource

      resource.add_observer self
      @routes[key(resource)] = resource
    end

    def update(resource, old_request_path)
      validate_request_path old_request_path
      validate_request_path resource
      validate_uniqueness resource

      @routes.delete key(old_request_path)
      @routes[key(resource)] = resource
    end

    def remove(resource)
      validate_request_path resource
      resource.delete_observer self
      @routes.delete key(resource)
      resource
    end

    def add_asset(asset, request_path: nil)
      add Resource.new asset: asset, request_path: asset_path_to_request_path(request_path || asset.to_request_path)
    end

    private
    def key(path)
      # TODO: Conslidate this into SafeRoot.
      File.join "/", validate_request_path(coerce_request_path(path))
    end

    def coerce_request_path(resource)
      resource.respond_to?(:request_path) ? resource.request_path : resource
    end

    def validate_request_path(path)
      path = coerce_request_path(path)
      raise InvalidRequestPathError, "path can't be nil" if path.nil?
      path
    end

    # Raise an exception if the user tries to add a Resource with an existing request path.
    def validate_uniqueness(resource)
      path = coerce_request_path(resource)
      if existing_resource = get(path)
        raise ExistingRequestPathError, "Resource #{existing_resource} already exists at #{path}"
      else
        resource
      end
    end

    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def asset_path_to_request_path(path)
      # Relative path of resource to the file_path of this project.
      relative_path = Pathname.new(path).relative_path_from(@root_file_path)
    end

    def safe_root
      @safe_root ||= SafeRoot.new(path: @root_file_path)
    end
  end
end
