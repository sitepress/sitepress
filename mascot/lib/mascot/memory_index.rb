module Mascot
  # Speeds up access to routes, but at the expense of lots of memory.
  class MemoryIndex
    def initialize
      reset
    end

    def index(resources)
      resources.each { |resource| @index[resource.request_path] = resource }
    end

    def get(request_path)
      @index[request_path]
    end

    def reset
      @index = Hash.new{ |h,k| h[k.to_s] }
    end
  end
end
