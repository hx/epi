require 'active_support/inflector'
require 'eventmachine'
require 'bson'

module Spagmon
  module Server
    class Receiver < EventMachine::Connection

      def receive_data(data)
        response = begin
          data = Hash.from_bson StringIO.new data
          {result: Responder.run(self, data.delete('type').to_s, data)}
        rescue => error
          {error: {
              class: error.class.name,
              message: error.message,
              backtrace: error.backtrace
          }}
        end
        response[:complete] = true
        send_data response.to_bson
      end

      def puts(text)
        data = {
            result: "#{text}\n",
            complete: false
        }
        send_data data.to_bson
      end

    end
  end
end
