require "fastimage"

module Sitepress
  # A source for image files. Extracts dimensions via fastimage.
  #
  # Example:
  #   image = Image.new(path: "photos/sunset.jpg")
  #   image.width   # => 1920
  #   image.height  # => 1080
  #   image.data["width"]  # => 1920
  #
  class Image < Static
    MIME_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze

    def self.mime_types
      MIME_TYPES
    end

    def filename
      path.basename.to_s
    end

    def size
      exists? ? File.size(path) : nil
    end

    def width
      dimensions[0]
    end

    def height
      dimensions[1]
    end

    def data
      @data ||= Data.manage({
        "width" => width,
        "height" => height
      }.compact)
    end

    private

    def dimensions
      @dimensions ||= begin
        return [nil, nil] unless exists?
        FastImage.size(path.to_s) || [nil, nil]
      rescue
        [nil, nil]
      end
    end
  end
end
