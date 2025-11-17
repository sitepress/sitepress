require "irb"

module Sitepress
  # Interactive REPL for Sitepress project
  class REPL
    def initialize(context:)
      @context = context
    end

    # Start interactive REPL.
    def start
      IRB.setup nil
      IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      require 'irb/ext/multi-irb'
      IRB.irb nil, @context
    end
  end
end
