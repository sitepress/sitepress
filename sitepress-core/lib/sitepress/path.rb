require "pathname"

module Sitepress
  class Path
    # Default handler extensions. Handlers are anything that render or
    # manipulate the contents of the file into a different output, like
    # ERB or HAML.
    HANDLER_EXTENSIONS = %i[haml erb md markdown]

    attr_reader :handler, :format, :path, :node_name

    # When Rails boots, it sets the handler extensions so that paths
    # can be properly parsed.
    class << self
      attr_writer :handler_extensions

      def handler_extensions
        @handler_extensions ||= HANDLER_EXTENSIONS
      end
    end

    def initialize(path, path_seperator: File::SEPARATOR, handler_extensions: self.class.handler_extensions)
      @path = path.to_s
      @path_seperator = Regexp.new(path_seperator)
      @handler_extensions = handler_extensions
      parse_basename
    end

    def node_names
      @node_names ||= node_name_ancestors.push(node_name)
    end

    private
      # Given a filename, this will work out the extensions, formats, and node_name.
      def parse_basename
        basename = File.basename(path)
        filename, extname = split_filename(basename)

        # This is a root path, so we have to treat it a little differently
        # so that the node mapper and node names work properly.
        if filename == "/" and extname.nil?
          @node_name = ""
        elsif extname
          extname = extname.to_sym

          # We have an extension! Let's figure out if its a handler or not.
          if @handler_extensions.include? extname
            # Yup, its a handler. Set those variables accordingly.
            @handler = extname
            basename = filename
          end

          # Now let's get the format (e.g. :html, :xml, :json) for the path and
          # the key, which is just the basename without the format extension.
          @node_name, format = split_filename(basename)
          @format = format.to_sym if format
        else
          @node_name = basename = filename
        end
      end

      # If given a path `/a/b/c`, thsi would return `["a", "b", "c"].
      def node_name_ancestors
        strip_leading_prefix(File.dirname(path)).split(@path_seperator)
      end

      # Make it easier to split the last extension off a filename.
      # For example, if you run `split_filename("c.taco.html")`
      # it would return `["c.taco", "html"]`. If you ran it against
      # something like `split_filename("c")`, it would return `["c"]`
      def split_filename(string)
        base, _, extension = string.rpartition(".")
        base.empty? ? [extension] : [base, extension]
      end

      # Strips leading `/` or leading `.` if the path is relative.
      def strip_leading_prefix(dirname)
        dirname.to_s.gsub(/^#{@path_seperator}|\./, "")
      end
  end
end
