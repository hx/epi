module Epi
  module Exceptions
    class InvalidConfigurationFile < Base

      attr_reader :data

      def initialize(message, data)
        super message
        @data = data
      end

    end
  end
end
