require 'forwardable'

module Epi

  # Manages running jobs
  module Jobs

    class << self
      extend Forwardable

      delegate [:[], :[]=, :delete, :each_value, :map, :find, :count] => :@jobs

      attr_reader :configuration_files

      def reset!
        @configuration_files = {}
        @jobs = {}
      end

      def beat!

        # Cancel any scheduled beats
        EventMachine.cancel_timer @next_beat if @next_beat

        # Make sure configuration files have been read
        refresh_config!

        # Snapshot currently running processes
        ProcessStatus.take!

        # Get rid of jobs for config files that have been removed
        clean_configuration_files!

        # Create new jobs
        make_new_jobs!

        # Sync each job with its expectations
        each_value &:sync!

        # Write state of each job to data file
        Data.jobs = map { |id, job| [id.to_s, job.state] }.to_h
        Data.save

        # Schedule the next beat
        @next_beat = EventMachine.add_timer(5) { beat! } # TODO: make interval configurable
      end

      def shutdown!(&callback)
        EventMachine.cancel_timer @next_beat if @next_beat
        ProcessStatus.take!
        remaining = count
        if remaining > 0
          each_value do |job|
            job.shutdown! do
              remaining -= 1
              callback.call if callback && remaining == 0
            end
          end
        else
          callback.call if callback
        end
      end

      def running_process_count
        each_value.map(&:running_count).reduce :+
      end

      def job_descriptions
        configuration_files.values.inject({}) { |all, conf_file| all.merge! conf_file.job_descriptions }
      end

      def refresh_config!
        Data.configuration_paths.each do |path|
          configuration_files[path] ||= ConfigurationFile.new(path)
        end
        configuration_files.each_value &:read
      end

      private

      def clean_configuration_files!
        to_remove = configuration_files.keys - Data.configuration_paths
        to_remove.each do |path|
          configuration_files.delete(path).job_descriptions.each_key do |job_id|
            job = delete(job_id)
            job.terminate! if job
          end
        end
      end

      def make_new_jobs!
        job_descriptions.each do |name, description|
          self[name] ||= Epi::Job.new(description, Data.jobs[name] || {})
        end
      end

    end

    # Set up class variables
    reset!

  end
end
