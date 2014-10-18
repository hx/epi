require 'eventmachine'

require_relative 'server/sender'
require_relative 'server/receiver'
require_relative 'server/responder'

module Spagmon
  module Server

    class << self

      def logger
        Spagmon.logger
      end

      def ensure_running
        should_run_as_root = Data.root?

        if running? && should_run_as_root && !process.root?
          logger.info "Server needs to run as root, but is running as #{process.user}"
          shutdown
        end

        unless running?
          if should_run_as_root && !Spagmon.root?
            raise Exceptions::Fatal, 'Found root data but not running as root. Either run again as root, ' +
                'or specify SPAGMON_HOME as a directory other than /etc/spagmon'
          end

          logger.info 'Starting server'
          %x(nohup #{$0} server run) if Process.fork.nil?
        end
      end

      def run
        raise Exception::Fatal, 'Server already running' if running?
        Data.server_pid = Process.pid
        Spagmon.beat!
        EM.add_periodic_timer(5) { Spagmon.beat! }
        logger.info "Starting server on #{HOST}:#{PORT}"
        EM.start_server HOST, PORT, Receiver
      end

      def send(*args)
        Sender.send *args
      end

      def shutdown(process = nil)
        process ||= self.process
        raise Exceptions::Fatal, 'Attempted to shut down server when no server is running' unless running?
        logger.info 'Server will shut down'
        if process.pid == Process.pid
          EventMachine.next_tick do
            EventMachine.stop_event_loop
            Data.server_pid = nil
            logger.info 'Server has shut down'
          end
        else
          send :shutdown
        end
      end

      def running?
        process && process.was_alive?
      end

      def process
        server_pid = Data.server_pid
        @process = nil if @process && @process.pid != server_pid
        @process ||= server_pid && RunningProcess.new(server_pid)
      end

    end

  end
end
