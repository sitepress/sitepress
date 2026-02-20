module Sitepress
  # Wraps a page in a class, which makes it much easier to decorate and validate.
  class Model
    attr_reader :page

    delegate \
      :request_path,
      :data,
      :asset,
      :body,
        to: :page

    delegate :save, to: :asset

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

      # Builds a collection from a block that returns resources.
      def collection(&)
        raise ArgumentError, "collection requires a block" unless block_given?
        build_collection(&)
      end

      # Adhoc querying of models via `Model.glob("foo/bar").all`
      def glob(glob, **)
        build_collection(model: self, **){ site.glob(glob) }
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

      private

      def build_collection(*, model: self, **, &)
        Models::Collection.new(*, model:, **, &)
      end
    end
  end
end
