require "mime/types"
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
  class Image
    MIME_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze

    def self.mime_types
      MIME_TYPES
    end

    attr_reader :path

    def initialize(path:)
      @path = Pathname.new(path)
    end

    def filename
      path.basename.to_s
    end

    def node_name
      path.basename(".*").to_s.split(".").first
    end

    def format
      path.extname.delete(".").to_sym
    end

    def mime_type
      MIME::Types.type_for(path.to_s).first
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

    def body
      File.binread(path)
    end

    def exists?
      path.exist?
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} path=#{path.to_s.inspect}>"
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
