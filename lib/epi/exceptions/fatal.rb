module Epi
  module Exceptions
    class Fatal < Base

      def initialize(*args)
        super *args
        Epi.logger.fatal message
      end

    end
  end
end
