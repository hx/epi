require 'forwardable'

module Spagmon
  class ProcessStatus

    class << self
      extend Forwardable

      def reset!
        @last = nil
      end

      # Current running processes
      # @return [self]
      def now
        new
      end

      # Take a snapshot of current running processes
      # @return [self]
      def take!
        @last = now
      end

      # The last snapshot taken by {#take}
      # @return [self]
      def last
        @last ||= take!
      end

      delegate [:[], :pids] => :last

    end

    # Lookup a running process by its PID
    # @param pid [String|Numeric] PID of the process to lookup
    # @return [RunningProcess|NilClass]
    def [](pid)
      pid = pid.to_i
      @running_processes[pid] ||= find_by_pid(pid)
    end

    # Get a list of PIDs of running processes
    # @return [Array] An array of PIDs as `Fixnum`s
    def pids
      @pids ||= @lines.keys
    end

    private

    def initialize

      # Cached running processes
      @running_processes = {}

      # Run `ps`
      result = %x(ps x -o #{RunningProcess::PS_FORMAT})

      # Split into lines, and get rid of the first (heading) line
      @lines = result.lines[1..-1].map { |line| [line.lstrip.split(/\s/, 2).first.to_i, line] }.to_h

    end

    def find_by_pid(pid)
      line = @lines[pid]
      RunningProcess.new(pid, line) if line
    end


  end
end
