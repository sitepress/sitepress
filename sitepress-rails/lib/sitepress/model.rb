module Sitepress
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
      def all(glob: self.path)
        Enumerator.new do |y|
          site.glob(glob).each { |page| y << new(page) }
        end
      end

      def attr_data(*keys, default: nil)
        keys.each do |key|
          define_method key do
            self.data.fetch key.to_s, default
          end
        end
      end

      def path(path=nil)
        if path
          @path = path
        else
          @path
        end
      end

      def site
        Sitepress.site
      end
    end
  end
end
