require 'eventmachine'
require 'bson'

module Spagmon
  class Pray < EventMachine::Connection

    def initialize(command, args)
      super
      data = {
          type: :command,
          command: command,
          args: args
      }
      send_data data.to_bson
    end

    def receive_data(data)
      puts data
      close_connection
      EventMachine.stop_event_loop
    end

  end
end
