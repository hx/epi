require 'eventmachine'

module Spagmon
  module Cli
    module Commands
      class Server < Command

        def run
          EventMachine.run do

            # Stir once...
            Spagmon.beat!

            # ...and keep stiring!
            EM.add_periodic_timer(5) { Spagmon.beat! }

            # Listen for other instructions and send them to the pot
            EM.start_server HOST, PORT, Spagmon::Server::Receiver
          end
        end

      end
    end
  end
end
