require_relative '../connection'

module Epi
  module Daemon
    class Sender < Connection
      include Exceptions

      # Send a message to the Epi server
      #
      # @example Get Epi's status
      #   Sender.send :status
      #
      # @example Add a config file
      #   Sender.send config: {add_paths: ['config.epi']}
      #
      # @param what [Hash|Symbol] Either a symbol being the message type, or a hash
      #   with a single key (a symbol) being the message type, and value (a hash) being the message.
      def self.send(what, &callback)

        raise ArgumentError, 'Expected a hash with one key (a symbol) and value (a hash)' unless
            Symbol === what ||
            (Hash === what && what.count == 1 && Symbol === what.keys.first && Hash === what.values.first)

        data = case what
          when Symbol then {type: what}
          when Hash then what.values.first.merge(type: what.keys.first)
          else nil
        end

        EventMachine.connect Daemon.socket_path.to_s, Sender, data, callback

      end

      def initialize(data, callback)
        @callback = callback
        send_object data
      end

      def receive_object(data)
        if data[:print]
          STDOUT << data[:print]
          return
        end

        if data.key? :result
          result = data[:result]

          if @callback
            @callback.call result
          else
            puts result unless result.nil?
            EM.stop
          end

        elsif data[:error]

          error = data[:error]
          if error[:class] == Fatal.name
            STDERR << error[:message]
            STDERR << "\n"
          else
            STDERR << "#{error[:class]}: #{error[:message]}\n"
            error[:backtrace].each { |x| STDERR << "\t#{x}\n" }
          end

          EM.stop
        end

        close_connection
      end

    end
  end
end
