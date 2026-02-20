require "irb"

module Sitepress
  # Interactive REPL for Sitepress project
  class REPL
    def initialize(context:)
      @context = context
    end

    def start
      ARGV.clear
      IRB.setup(nil)
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      workspace = IRB::WorkSpace.new(@context)
      IRB::Irb.new(workspace).run(IRB.conf)
    end
  end
end
