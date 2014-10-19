module Spagmon
  module Jobs

    @configuration_files = {}

    class << self

      attr_reader :configuration_files

      def job_descriptions
        configuration_files.inject({}) { |all, conf_file| all.merge! conf_file.job_descriptions }
      end

      def refresh_config!
        Data.configuration_paths.each do |path|
          configuration_files[path] ||= ConfigurationFile.new(path)
        end
        clean_configuration_files!
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
