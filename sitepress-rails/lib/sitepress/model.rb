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

    class << self
      def collection(name = Models::Collection::DEFAULT_NAME, **kwargs)
        define_singleton_method name do
          Models::Collection.new model: self, site: site, **kwargs
        end
      end

      # Wraps a page in a class if given a string that represents the path or
      # a page object itself.
      def get(page)
        case page
        when Model
          page
        when String
          new site.get page
        when Sitepress::Resource
          new page
        else
          raise ModelNotFoundError, "#{self.inspect} could not find #{page.inspect}"
        end
      end
      alias :find :get

      def attr_data(*keys, default: nil)
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
