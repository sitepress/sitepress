require "fileutils"
require "digest/sha1"
require "tmpdir"

module Mascot
  # Speeds up access to routes, but at the expense of lots of memory.
  class DiskIndex
    def initialize(dir: Dir.mktmpdir)
      @dir = Pathname.new(dir)
      reset
    end

    def index(resources)
      resources.each { |resource| add resource }
    end

    def add(resource)
      dump = Marshal.dump(resource)
      digest = Digest::SHA1.hexdigest(dump)
      dump_path = @dir.join(digest).to_s
      File.write dump_path, dump
      @index[resource.request_path] = dump_path
    end

    def get(request_path)
      Marshal.load File.read @index[request_path]
    end

    def reset
      FileUtils.rm_rf @dir
      FileUtils.mkdir_p @dir
      @index = Hash.new{ |h,k| h[k.to_s] }
    end
  end
end
