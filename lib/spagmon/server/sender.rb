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
      # @example Shut down the server
      #   Sender.send :shutdown
      #
      # @param what [Hash|Symbol] Either a symbol being the message type, or a hash
      #   with a single key (a symbol) being the message type, and value (a hash) being the message.
      def self.send(what)

        raise ArgumentError, 'Expected a hash with one key (a symbol) and value (a hash)' unless
            Symbol === what ||
            (Hash === what && what.count == 1 && Symbol === what.keys.first && Hash === what.values.first)

        data = case what
          when Symbol then {type: what}
          when Hash then what.values.first.merge(type: what.keys.first)
          else nil
        end

        EventMachine.connect Server.socket_path.to_s, Sender, data

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
          if error['class'] == Fatal.name
            STDERR << error['message']
            STDERR << "\n"
          else
            puts "#{error['class']}: #{error['message']}"
            error['backtrace'].each { |x| puts '  ' << x }
          end
        end

        if data['complete']
          close_connection
          EventMachine.stop_event_loop
        end
      end

    end
  end
end
