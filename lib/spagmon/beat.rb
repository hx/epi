module Spagmon
  def self.beat!

    # Make sure configuration files have been read
    Jobs.refresh_config!

    # Snapshot currently running processes

    # Kill any jobs that shouldn't be running

    # Process event handlers

    # Start any jobs that should be running

  end
end
