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

    def self.unmanage(data)
      case data
      when Record, Collection
        data.unmanage
      else
        data
      end
    end

    # Wraps an array and returns managed elements
    class Collection
      include Enumerable
      extend Forwardable

      def_delegators :@array, :each, :[]

      def initialize(array)
        @array = array.map { |element| Data.manage(element) }
      end

      def unmanage
        @array.map { |value| Data.unmanage(value) }
      end
    end

    # Wraps a hash and returns managed elements
    class Record
      include Enumerable
      extend Forwardable

      def_delegators :@hash, :keys, :values, :key?

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

      def unmanage
        @hash.transform_values { |value| Data.unmanage(value) }
      end

      def method_missing(name, *args, **kwargs, &block)
        if respond_to? name
          self.send name, *args, **kwargs, &block
        else
          key, modifier, _ = name.to_s.partition(/[!?]/)

          case modifier
          when ""
            self[key]
          when "!"
            self.fetch(key, *args, &block)
          when "?"
            !!self[key]
          end
        end
      end

      def dig(*args, **kwargs, &block)
        Data.manage @hash.dig(*args, **kwargs, &block)
      end
    end
  end
end
