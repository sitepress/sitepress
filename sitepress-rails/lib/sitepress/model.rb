module Sitepress
  # Wraps a page in a class, which makes it much easier to decorate and validate.
  class Model
    attr_reader :page

    delegate \
      :request_path,
      :data,
      :body,
        to: :page

    def initialize(page)
      @page = page
    end

    # Treat as equal if the resource and model class are the same.
    def ==(model)
      self.page == model.page and self.class == model.class
    end

    class << self
      delegate \
        :first,
          to: :all

      # Defines a class method that may be called later to return a
      # collection of objects. The default glob, for example, is named `:all`,
      # which defines `MyModel.all` on the class.
      def collection(name = Models::Collection::DEFAULT_NAME, glob:, **kwargs)
        define_singleton_method name do
          self.glob glob, **kwargs
        end
      end

      # Adhoc querying of models via `Model.glob("foo/bar").all`
      def glob(glob, **kwargs)
        Models::Collection.new model: self, site: site, glob: glob, **kwargs
      end

      # Wraps a page in a class if given a string that represents the path or
      # a page object itself.
      def get(page)
        case page
        when Model
          page
        when String
          get site.get page
        when Sitepress::Resource
          new page
        else
          nil
        end
      end
      alias :find :get

      def data(*keys, default: nil)
        keys.each do |key|
          define_method key do
            self.data.fetch key.to_s, default
          end
        end
      end

      def site
        Sitepress.site
      end
    end
  end
end
