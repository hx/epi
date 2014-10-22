require 'forwardable'

module Spagmon
  class Job
    extend Forwardable

    attr_reader :job_description
    attr_accessor :expected_count

    delegate [:name, :id, :allowed_processes] => :job_description

    def logger
      Spagmon.logger
    end

    def initialize(job_description, state)
      @job_description = job_description
      @expected_count = state['expected_count'] || job_description.initial_processes
      @pids = state['pids']
      @dying_pids = state['dying_pids']
    end

    # noinspection RubyStringKeysInHashInspection
    def state
      {
          'expected_count' => expected_count,
          'pids' => pids,
          'dying_pids' => dying_pids
      }
    end

    # Get a hash of PIDs, with internal process IDs as keys and PIDs as values
    # @example `{'1a2v3c4d' => 4820}`
    # @return [Hash]
    def pids
      @pids ||= {}
    end

    # Get a hash of PIDs, with internal process IDs as keys and PIDs as values,
    # for process that are dying
    # @example `{'1a2v3c4d' => 4820}`
    # @return [Hash]
    def dying_pids
      @dying_pids ||= {}
    end

    # Get the data key for the PID file of the given process ID or PID
    # @param [String|Fixnum] proc_id Example: `'1a2b3c4d'` or `1234`
    # @return [String|NilClass] Example: `pids/job_id/1ab3c4d.pid`, or `nil` if not found
    def pid_key(proc_id)
      proc_id = pids.key(proc_id) if Fixnum === proc_id
      proc_id && job_description.pid_key(proc_id)
    end

    # Stops processes that shouldn't run, starts process that should run, and
    # fires event handlers
    def sync!

      # Remove non-running PIDs from the list
      pids.reject { |_, pid| ProcessStatus.pids.include? pid }.each do |proc_id, pid|
        logger.debug "Lost process #{pid}"
        pids.delete proc_id
      end

      # Remove non-running PIDs from the dying list. This is just in case
      # the daemon crashed before it was able to clean up a dying worker
      # (i.e. it sent a TERM but didn't get around to sending a KILL)
      dying_pids.select! { |_, pid| ProcessStatus.pids.include? pid }

      # TODO: clean up processes that never died how they should have

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
      proc_id, pid = job_description.launch
      pids[proc_id] = pid
      Data.write pid_key(proc_id), pid
    end

    def stop_one
      proc_id, pid = pids.shift
      dying_pids[proc_id] = pid
      work = proc do
        ProcessStatus[pid].kill job_description.kill_timeout
      end
      done = proc do
        dying_pids.delete proc_id
        Data.write pid_key(proc_id), nil
      end
      EventMachine.defer work, done
    end

  end
end
