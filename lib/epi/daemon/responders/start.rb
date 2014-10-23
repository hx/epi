module Epi
  module Daemon
    module Responders

      class Start < Responder

        def run
          count = Jobs.running_process_count
          if count == 0
            'Starting ...'
          else
            "Starting #{count} process#{count == 1 ? '' : 'es'} ..."
          end
        end

      end
    end
  end
end
