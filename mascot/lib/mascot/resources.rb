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

    def glob(pattern = "**/**")
      paths = safe_root.glob @root_file_path.join(pattern)
      select { |r| paths.include? r.asset.path.to_s}
    end

    def get(request_path)
      return if request_path.nil?
      @routes[key(request_path)]
    end

    def add(resource)
      return if resource.nil?
      resource.add_observer self
      @routes[key(resource)] = resource
    end

    def update(resource, old_request_path)
      return if resource.nil?
      @routes.delete key(old_request_path)
      @routes[key(resource)] = resource
    end

    def remove(resource)
      return if resource.nil?
      resource.delete_observer self
      @routes.delete key(resource)
      resource
    end

    def add_asset(asset, request_path: nil)
      add Resource.new asset: asset, request_path: asset_path_to_request_path(request_path || asset.path)
    end

    private
    def key(path)
      raise "invalid key" if path.nil?
      path = path.request_path if path.respond_to? :request_path
      File.join("/", path)
    end
    # Given a @file_path of `/hi`, this method changes `/hi/there/friend.html.erb`
    # to an absolute `/there/friend` format by removing the file extensions
    def asset_path_to_request_path(path)
      # Relative path of resource to the file_path of this project.
      relative_path = Pathname.new(path).relative_path_from(@root_file_path)
      # Removes the .fooz.baz
      File.join("/", relative_path).to_s.sub(/\..*/, '')
    end

    def safe_root
      @safe_root ||= SafeRoot.new(path: @root_file_path)
    end
  end
end
