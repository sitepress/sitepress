require "async"

module Sitepress
  # Runs multiple processes concurrently, with colored and labeled output.
  class ProcessSupervisor
    ANSI_COLORS = {
      red:     "\e[31m",
      green:   "\e[32m",
      yellow:  "\e[33m",
      blue:    "\e[34m",
      magenta: "\e[35m",
      cyan:    "\e[36m",
      reset:   "\e[0m"
    }.freeze

    attr_reader :processes

    def initialize
      @processes = []
      @mutex = Mutex.new
    end

    def add(process)
      process.color = Process.color_for_index(@processes.size)
      @processes << process
    end

    # Run all processes concurrently using Async.
    # This method blocks until all processes exit.
    def run
      return if @processes.empty?

      Sync do |task|
        @processes.each do |process|
          task.async do
            run_process(process)
          end
        end
      end
    end

    private

    def run_process(process)
      process.run do |line|
        output(process, line)
      end
    rescue => e
      output(process, "Error: #{e.message}")
    end

    def output(process, line)
      color = ANSI_COLORS[process.color] || ""
      reset = ANSI_COLORS[:reset]
      label = process.label.to_s.ljust(max_label_length)

      @mutex.synchronize do
        puts "#{color}[#{label}]#{reset} #{line}"
      end
    end

    def max_label_length
      @max_label_length ||= @processes.map { |p| p.label.to_s.length }.max || 0
    end
  end
end
