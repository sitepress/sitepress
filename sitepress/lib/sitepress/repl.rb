require "irb"

module Sitepress
  # Interactive REPL for Sitepress project
  class REPL
    attr_reader :site

    def initialize(site:)
      @site = site
    end

    def start
      ARGV.clear
      IRB.setup(nil)
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      workspace = IRB::WorkSpace.new(binding)
      IRB::Irb.new(workspace).run(IRB.conf)
    end

    # Provide convenient access in the REPL
    def resources
      site.resources
    end

    def get(path)
      site.get(path)
    end
  end
end
