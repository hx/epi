module Spagmon
  class Job

    attr_reader :job_description, :desired_process_count

    def initialize

    end

    # Stops processes that shouldn't run, starts process that should run, and
    # fires event handlers
    def sync!

    end

    def desired_process_count=(value)

    end

    def running_process_count

    end

  end
end
