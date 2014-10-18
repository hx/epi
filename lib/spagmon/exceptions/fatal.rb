module Spagmon
  module Exceptions
    class Fatal < Base

      def initialize(*args)
        super *args
        Spagmon.logger.fatal message
      end

    end
  end
end
