require 'eventmachine'
require 'bson'

module Spagmon
  module Server
    class Receiver < EventMachine::Connection

      def receive_data(data)
        response = begin
          data = Hash.from_bson StringIO.new data
          {result: Responder.run(self, data.delete('type').to_s, data)}
        rescue Exceptions::Shutdown
          self.should_shut_down = true
          {result: 'Server is shutting down'}
        rescue => error
          {error: {
              class: error.class.name,
              message: error.message,
              backtrace: error.backtrace
          }}
        end
        response[:complete] = true
        send_data response.to_bson
        EventMachine.next_tick { EventMachine.stop_event_loop } if should_shut_down
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
