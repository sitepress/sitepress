require "mime/types"
require "forwardable"
require "pathname"

module Mascot
  # Represents a file on a web server that may be parsed to extract
  # frontmatter or be renderable via a template. Multiple resources
  # may point to the same asset. Properties of an asset should be mutable.
  # The Resource object is immutable and may be modified by the Resources proxy.
  class Asset
    # If we can't resolve a mime type for the resource, we'll fall
    # back to this binary octet-stream type so the client can download
    # the resource and figure out what to do with it.
    DEFAULT_MIME_TYPE = MIME::Types["application/octet-stream"].first

    attr_reader :path

    extend Forwardable
    def_delegators :frontmatter, :data, :body

    def initialize(path: , mime_type: nil)
      # The MIME::Types gem returns an array when types are looked up.
      # This grabs the first one, which is likely the intent on these lookups.
      @mime_type = Array(mime_type).first
      @path = Pathname.new path
    end

    # List of all file extensions.
    def extensions
      path.basename.to_s.split(".").drop(1)
    end

    # Returns the format extension.
    def format_extension
      extensions.first
    end

    # Returns a list of the rendering extensions.
    def template_extensions
      extensions.drop(1)
    end

    # Treat resources with the same request path as equal.
    def ==(asset)
      path == asset.path
    end

    def mime_type
      @mime_type ||= Array(inferred_mime_type).first || DEFAULT_MIME_TYPE
    end

    private
    def frontmatter
      Frontmatter.new File.read @path
    end

    # Returns the mime type of the file extension. If a type can't
    # be resolved then we'll just grab the first type.
    def inferred_mime_type
      MIME::Types.type_for(format_extension) if format_extension
    end
  end
end
