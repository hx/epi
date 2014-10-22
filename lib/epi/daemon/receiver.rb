require_relative '../connection'

module Epi
  module Daemon
    class Receiver < Connection

      def logger
        Epi.logger
      end

      def receive_object(data)
        logger.debug "Received message of type '#{data['type']}'"
        begin
          Responder.run(self, data.delete('type').to_s, data) { |result| send_object result: result }
        rescue Exceptions::Shutdown
          send_object result: nil
          Daemon.shutdown
        rescue => error
          send_object error: {
              class: error.class.name,
              message: error.message,
              backtrace: error.backtrace
          }
        end
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
