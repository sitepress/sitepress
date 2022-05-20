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
