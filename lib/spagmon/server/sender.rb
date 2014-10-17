require 'eventmachine'
require 'bson'

module Spagmon
  module Server
    class Sender < EventMachine::Connection
      include Exceptions

      # Send a message to the Spagmon server
      #
      # @example Get Spagmon's status
      #   Sender.send command: {command: 'status', arguments: []}
      #
      # @param what [Hash] A hash with a single key (a symbol) being the message type,
      #   and value (a hash) being the message.
      def self.send(what)

        raise ArgumentError, 'Expected a hash with one key (a symbol) and value (a hash)' unless
            Hash === what && what.count == 1 && Symbol === what.keys.first && Hash === what.values.first

        EventMachine.run do
          EventMachine.connect HOST, PORT, Sender, what.values.first.merge(type: what.keys.first)
        end

      end

      def initialize(data)
        send_data data.to_bson
      end

      def receive_data(data)
        data = Hash.from_bson StringIO.new data

        if data['result']
          puts data['result']

        elsif data['error']
          error = data['error']
          puts "#{error['class']}: #{error['message']}"
          error['backtrace'].each { |x| puts '  ' << x }
        end

        if data['complete']
          close_connection
          EventMachine.stop_event_loop
        end
      end

    end
  end
end
