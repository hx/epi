require 'forwardable'

module Spagmon
  class Job
    extend Forwardable

    attr_reader :job_description, :pids, :dying_pids
    attr_accessor :expected_count

    delegate [:name, :id, :allowed_processes] => :job_description

    def initialize(job_description, expected_count, pids = nil)
      @job_description = job_description
      @expected_count = expected_count || job_description.initial_processes
      @pids = pids || []
      @dying_pids = []
    end

    # Stops processes that shouldn't run, starts process that should run, and
    # fires event handlers
    def sync!

      # Remove non-running PIDs from the list
      @pids &= ProcessStatus.pids

      # Run new processes
      start_one while running_count < expected_count

      # Kill old processes
      stop_one while running_count > expected_count
    end

    def terminate!
      self.expected_count = 0
      sync!
    end

    def running_count
      pids.count
    end

    private

    def start_one
      pids << job_description.launch
    end

    def stop_one
      pid = pids.shift
      @dying_pids << pid
      work = proc { ProcessStatus[pid].kill job_description.kill_timeout }
      done = proc { @dying_pids.delete pid }
      EventMachine.defer work, done
    end

  end
end
