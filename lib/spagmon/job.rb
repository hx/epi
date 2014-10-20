module Spagmon
  class Job

    attr_reader :job_description, :pids
    attr_accessor :expected_count

    def initialize(job_description, expected_count, pids)
      @job_description = job_description
      @expected_count = expected_count || 0
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
      work = -> { ProcessStatus[pid].kill job_description.kill_timeout }
      done = -> { @dying_pids.delete pid }
      EventMachine.defer work, done
    end

  end
end
