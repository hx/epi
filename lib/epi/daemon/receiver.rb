require_relative '../connection'

module Epi
  module Daemon
    class Receiver < Connection

      def logger
        Epi.logger
      end

      def receive_object(data)
        should_shut_down = false
        response = begin
          logger.debug "Received message of type '#{data['type']}'"
          {result: Responder.run(self, data.delete('type').to_s, data)}
        rescue Exceptions::Shutdown
          should_shut_down = true
          {result: nil}
        rescue => error
          {error: {
              class: error.class.name,
              message: error.message,
              backtrace: error.backtrace
          }}
        end
        send_object response
        Daemon.shutdown if should_shut_down
      end

      def puts(text)
        print "#{text}\n"
      end

      def print(text)
        send_object print: text.to_s
      end

    end
  end
end
