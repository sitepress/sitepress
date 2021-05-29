require "mime/types"
require "forwardable"
require "pathname"

module Sitepress
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
    def_delegators :path, :handler, :node_name, :format, :exists?

    def initialize(path: , mime_type: nil)
      # The MIME::Types gem returns an array when types are looked up.
      # This grabs the first one, which is likely the intent on these lookups.
      @mime_type = Array(mime_type).first
      @path = Path.new path
    end

    # Treat resources with the same request path as equal.
    def ==(asset)
      path == asset.path
    end

    def mime_type
      @mime_type ||= inferred_mime_type || DEFAULT_MIME_TYPE
    end

    # Used by the Rails controller to short circuit additional processing if the
    # asset is not renderable (e.g. is it erb or haml?)
    def renderable?
      !!handler
    end

    private
      def frontmatter
        Frontmatter.new File.read path
      end

      # Returns the mime type of the file extension. If a type can't
      # be resolved then we'll just grab the first type.
      def inferred_mime_type
        format_extension = path.format&.to_s
        MIME::Types.type_for(format_extension).first if format_extension
      end
  end
end
