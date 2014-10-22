module Epi
  module Daemon
    module Responders
      # noinspection RubyStringKeysInHashInspection
      class StopAll < Responder

        def run_async
          count = Jobs.running_process_count
          if count > 0
            puts "Stopping #{count} process#{count == 1 ? '' : 'es'} ..."
            Jobs.shutdown! { done }
          else
            done
          end
        end

      end
    end
  end
end
