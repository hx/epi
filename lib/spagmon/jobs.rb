require 'forwardable'

module Spagmon

  # Manages running jobs
  module Jobs

    @configuration_files = {}
    @jobs = {}

    class << self
      extend Forwardable

      delegate [:[], :[]=, :delete, :each_value, :map] => :@jobs

      attr_reader :configuration_files

      def beat!
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

        # Write PIDs of each job to data file
        Data.processes = map { |id, job| [id.to_s, job.pids] }.to_h
        Data.save
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
          self[name] ||= Job.new(description, 0, Data.processes[name])
        end
      end

    end

  end
end
