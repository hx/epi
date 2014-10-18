require_relative 'process_status/running_process'

module Spagmon
  class ProcessStatus

    def self.now
      new
    end

    # Lookup a running process by its PID
    # @param pid [String|Numeric] PID of the process to lookup
    # @return [RunningProcess|NilClass]
    def [](pid)
      pid = pid.to_i
      @running_processes[pid] ||= find_by_pid(pid)
    end

    private

    def initialize

      # Cached running processes
      @running_processes = {}

      # Run `ps`
      result = %x(ps x -o #{RunningProcess::PS_FORMAT})

      # Split into lines, and get rid of the first (heading) line
      @lines = result.lines[1..-1]

    end

    def find_by_pid(pid)
      line = @lines.find { |line| line[0..6].strip == pid.to_s }
      RunningProcess.new(pid, line) if line
    end


  end
end
