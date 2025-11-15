require "pathname"
require "mime-types"

module Sitepress
  class Path
    # Default handler extensions. Handlers are anything that render or
    # manipulate the contents of the file into a different output, like
    # ERB or HAML.
    HANDLER_EXTENSIONS = %i[haml erb md markdown]

    # The root node name is a blank string.
    ROOT_NODE_NAME = "".freeze

    # The name of the root path
    ROOT_PATH = "/".freeze

    attr_reader :handler, :format, :path, :node_name, :dirname, :basename

    # When Rails boots, it sets the handler extensions so that paths
    # can be properly parsed.
    class << self
      def handler_extensions
        action_view_template_handlers_extensions || HANDLER_EXTENSIONS
      end

      # I tried to hook this into Rails engines in the `config.after_initialize` block,
      # but the way template handlers register their extensions is across the board.
      #
      # config.after_initialize do
      #   Sitepress::Path.handler_extensions = ActionView::Template::Handlers.method(:extensions)
      # ends
      #
      # I couldn't get that working, instead I do this check to find the handlers.
      def action_view_template_handlers_extensions
        ActionView::Template::Handlers.extensions if defined?(ActionView::Template::Handlers)
      end
    end

    def initialize(path, path_seperator: File::SEPARATOR, handler_extensions: self.class.handler_extensions)
      @path = path.to_s
      @path_seperator = Regexp.new(path_seperator)
      @handler_extensions = handler_extensions
      parse
    end

    def node_names
      @node_names ||= node_name_ancestors.push(node_name)
    end

    # Necessary for operations like `File.read path` where `path` is an instance
    # of this object.
    def to_str
      @path
    end
    alias :to_s :to_str

    def ==(path)
      to_s == path.to_s
    end

    def exists?
      File.exist? path
    end

    def expand_path
      File.expand_path path
    end

    def format
      (handler_is_format? ? handler : @format)&.to_sym
    end

    def relative_path_from(target)
      Pathname.new(@path).relative_path_from(target).to_s
    end

    private

      # Rails has handlers, like `:html` and `:raw` that are both
      # handlers and formats. If we don't account for this, then the object
      # would return a `nil` for a file named `blah.html`.
      def handler_is_format?
        return false if @handler.nil?
        @format.nil? and MIME::Types.type_for(@handler.to_s).any?
      end

      def parse
        @dirname, @basename = File.split(path)
        parse_basename
      end

      # Given a filename, this will work out the extensions, formats, and node_name.
      def parse_basename
        base = basename
        filename, extname = split_filename(base)

        # This is a root path, so we have to treat it a little differently
        # so that the node mapper and node names work properly.
        if filename == ROOT_PATH and extname.nil?
          @node_name = ROOT_NODE_NAME
        elsif extname
          extname = extname.to_sym

          # We have an extension! Let's figure out if its a handler or not.
          if @handler_extensions.include? extname
            # Yup, its a handler. Set those variables accordingly.
            @handler = extname
            base = filename
          end

          # Now let's get the format (e.g. :html, :xml, :json) for the path and
          # the key, which is just the basename without the format extension.
          @node_name, format = split_filename(base)
          @format = format
        else
          @node_name = filename
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
