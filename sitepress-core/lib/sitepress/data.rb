module Sitepress
  class Data
    def initialize(data)
      @data = data
    end

    def fetch(key, *args, &block)
      wrap_value { @data.fetch(key.to_s, *args, &block) }
    end

    def [](key)
      wrap_value { @data[key.to_s] }
    end

    def method_missing(name, *args, **kwargs, &block)
      if respond_to? name
        self.send name, *args, **kwargs, &block
      else
        key, modifier, _ = name.to_s.partition("!")
        wrap_value do
          case modifier
          when ""
            @data[key]
          when "!"
            @data.fetch(key)
          end
        end
      end
    end

    def dig(*args, **kwargs, &block)
      wrap_value { @data.dig(*args, **kwargs, &block) }
    end

    private
      def wrap_value(&block)
        case value = block.call
        when Hash
          self.class.new value
        when Array
          value.map { |v| wrap_value { v } }
        else
          value
        end
      end
  end
end
