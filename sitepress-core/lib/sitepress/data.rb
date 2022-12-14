module Sitepress
  module Data
    def self.manage(value)
      case value
      when Hash
        Record.new value
      when Array
        Collection.new value
      else
        value
      end
    end

    # Wraps an array and returns managed elements
    class Collection
      include Enumerable
      extend Forwardable

      def_delegators :@array, :each, :[]

      def initialize(array)
        @array = array.map do |element|
          Data.manage(element)
        end
      end
    end

    # Wraps a hash and returns managed elements
    class Record
      include Enumerable

      def initialize(hash)
        @hash = hash
      end

      def fetch(key, *args, &block)
        Data.manage(@hash.fetch(key.to_s, *args, &block))
      end

      def [](key)
        Data.manage(@hash[key.to_s])
      end

      def []=(key, value)
        Data.manage(@hash[key.to_s] = value)
      end

      def each
        @hash.each do |key, value|
          yield key, Data.manage(value)
        end
      end

      def method_missing(name, *args, **kwargs, &block)
        if respond_to? name
          self.send name, *args, **kwargs, &block
        else
          key, modifier, _ = name.to_s.partition("!")

          case modifier
          when ""
            self[key]
          when "!"
            self.fetch(key, *args, &block)
          end
        end
      end

      def dig(*args, **kwargs, &block)
        Data.manage @hash.dig(*args, **kwargs, &block)
      end
    end
  end
end
