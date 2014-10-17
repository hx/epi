require 'eventmachine'

module Spagmon
  module Cli
    module Commands
      class Reign < Command

        def run
          EventMachine.run do

            # Stir once...
            Spagmon.stir!

            # ...and keep stiring!
            EM.add_periodic_timer(5) { Spagmon.stir! }

            # Listen for other instructions and send them to the pot
            EM.start_server HOST, PORT, Pot
          end
        end

      end
    end
  end
end
