require 'eventmachine'
require 'bson'

module Epi
  module Daemon
    class Receiver < EventMachine::Connection

      def logger
        Epi.logger
      end

      def receive_data(data)
        response = begin
          data = Hash.from_bson StringIO.new data
          logger.debug "Received message of type '#{data['type']}'"
          {result: Responder.run(self, data.delete('type').to_s, data)}
        rescue Exceptions::Shutdown
          self.should_shut_down = true
          {result: nil}
        rescue => error
          {error: {
              class: error.class.name,
              message: error.message,
              backtrace: error.backtrace
          }}
        end
        response[:complete] = true
        send_data response.to_bson
        Daemon.shutdown if should_shut_down
      end

      def puts(text)
        data = {
            result: "#{text}\n",
            complete: false
        }
        send_data data.to_bson
      end

      private

      attr_accessor :should_shut_down

    end
  end
end
