require 'forwardable'

module Spagmon

  # Manages running jobs
  module Jobs

    @configuration_files = {}
    @jobs = {}

    class << self
      extend Forwardable

      delegate [:[], :[]=] => :@jobs

      attr_reader :configuration_files

      def beat!
        # Make sure configuration files have been read
        refresh_config!

        # Get rid of jobs for config files that have been removed
        clean_configuration_files!

        # Snapshot currently running processes
        ProcessStatus.take!

        # Sync each job with its expectations
        @jobs.each_value &:sync!
      end

      def job_descriptions
        configuration_files.inject({}) { |all, conf_file| all.merge! conf_file.job_descriptions }
      end

      def refresh_config!
        Data.configuration_paths.each do |path|
          configuration_files[path] ||= ConfigurationFile.new(path)
        end
        configuration_files.each_value &:read
      end

      private

      def clean_configuration_files!
        to_remove = @configuration_files.keys - Data.configuration_paths
        to_remove.each do |path|
          # TODO: remove config for this path
        end
      end

    end

  end
end
