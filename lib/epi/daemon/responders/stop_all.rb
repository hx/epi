module Epi
  module Daemon
    module Responders
      # noinspection RubyStringKeysInHashInspection
      class StopAll < Responder

        def run
          puts 'Stopping all processes ...'
          # TODO: stop them. For reals.
        end

      end
    end
  end
end
