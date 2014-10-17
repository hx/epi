require 'eventmachine'
require 'yaml'

module Spagmon
  class Pot < EventMachine::Connection

    def receive_data(data)
      data = Hash.from_bson StringIO.new data
      case data[:type]
        when :command then Command.run data[:command], data[:args]
        else 'I got nothing'
      end
    end

  end
end
