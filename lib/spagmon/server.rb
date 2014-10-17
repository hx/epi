require 'eventmachine'

require_relative 'server/sender'
require_relative 'server/receiver'
require_relative 'server/responder'

module Spagmon
  module Server

    def self.run
      EventMachine.run do
        Spagmon.beat!
        EM.add_periodic_timer(5) { Spagmon.beat! }
        EM.start_server HOST, PORT, Receiver
      end
    end

    def self.send(*args)
      Sender.send *args
    end

  end
end
