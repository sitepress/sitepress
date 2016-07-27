require "pathname"

module Mascot
  # Validates if a path is within another path. This prevents
  # users from accidentally selecting a file outside of their sitemap,
  # which could be insured.
  class SafeRoot
    def initialize(path: )
      @path = Pathname.new(path)
    end

    # Validates if a path is safe by checking if its within a folder.
    def safe?(path)
      root_path = File.expand_path(@path)
      resource_path = File.expand_path(path)

      if resource_path.start_with? root_path
        path
      else
      end
    end

    def glob(pattern)
      Dir[validate(pattern)]
    end

    def unsafe?(path)
      not safe? path
    end

    def path
    end

    def validate(path)
      if unsafe? path
        raise Mascot::UnsafePathAccessError, "Unsafe attempt to access #{path} outside of #{@path}"
      else
        path
      end
    end
  end
end
