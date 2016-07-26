require "pathname"

module Mascot
  # Validates if a path is within another path. This prevents
  # users from accidentally selecting a file outside of their sitemap,
  # which could be insured.
  class PathValidator
    def initialize(safe_path: )
      @safe_path = Pathname.new(safe_path)
    end

    # Validates if a path is safe by checking if its within a folder.
    def safe?(path)
      root_path = File.expand_path(@safe_path)
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

    def validate(path)
      if unsafe? path
        raise Mascot::UnsafePathAccessError, "Unsafe attempt to access #{path} outside of #{@safe_path}"
      else
        path
      end
    end
  end
end
