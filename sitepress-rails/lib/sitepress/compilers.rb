module Sitepress
  # A dumb collection of compiler instances. Holds anything that
  # responds to `#compile` (typically `Sitepress::Compiler::Files`),
  # and runs them in order when you call `#compile`. The collection
  # has no opinion about how its members were constructed, where they
  # write, or what sites they're bound to — that's all the caller's
  # job.
  #
  #   compilers = Sitepress::Compilers.new
  #   compilers << Sitepress::Compiler::Files.new(site: foo, root_path: "build/foo")
  #   compilers << Sitepress::Compiler::Files.new(site: bar, root_path: "build/bar")
  #   compilers.compile
  #
  # `Enumerable` is mixed in, so `compilers.flat_map(&:succeeded)`
  # and `compilers.flat_map(&:failed)` work for aggregating across
  # the underlying compilers.
  class Compilers
    include Enumerable

    def initialize(compilers = [])
      @compilers = compilers.to_a
    end

    # Add a single compiler to the collection. Returns self per Ruby's
    # `<<` convention so additions chain.
    def <<(compiler)
      @compilers << compiler
      self
    end

    # Merge an iterable of compilers into the collection. Mirrors
    # `Array#concat` — accepts anything responding to `#to_a` (Array,
    # another Compilers, lazy enumerator, etc.) and adds each element
    # individually.
    #
    #   compilers.concat([c1, c2, c3])
    #   compilers.concat(other_compilers)
    #   compilers.concat(sites.map { |s| Compiler::Files.new(...) })
    #
    # Returns self for chaining.
    def concat(other)
      @compilers.concat(other.to_a)
      self
    end

    # Run `#compile` on every compiler in the collection in order.
    # Returns self for chaining.
    def compile
      @compilers.each(&:compile)
      self
    end

    def each(&block)
      @compilers.each(&block)
    end
  end
end
