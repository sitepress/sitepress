module Sitepress
  # Represents a labeled shell command that runs as part of the development server.
  # Used for things like Tailwind CSS watchers, esbuild, etc.
  class Process
    COLORS = [:red, :green, :yellow, :blue, :magenta, :cyan].freeze

    attr_reader :label, :command
    attr_accessor :color

    def initialize(label:, command:)
      @label = label.to_sym
      @command = command
      @color = nil
      @pid = nil
    end

    # Run the process, yielding each line of output.
    # This blocks until the process exits.
    def run(&block)
      IO.popen(command, err: [:child, :out]) do |io|
        io.each_line do |line|
          yield line.chomp if block_given?
        end
      end
    end

    # Assign a color based on index (for supervisor to assign unique colors)
    def self.color_for_index(index)
      COLORS[index % COLORS.length]
    end
  end
end
