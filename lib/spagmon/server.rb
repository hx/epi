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
          Spagmon.launch [$0, 'server', 'run'],
                         stdout: Data.home + 'server.log',
                         stderr: Data.home + 'server_errors.log'

          begin
            Timeout::timeout(5) { sleep 0.05 until socket_path.exist? }
          rescue Timeout::Error
            raise Exceptions::Fatal, 'Server not started after 5 seconds'
          end unless socket_path.exist?
        end
      end

      def socket_path
        Data.home + 'socket'
      end

      def run
        raise Exceptions::Fatal, 'Server already running' if running?

        # Save the server PID
        Data.server_pid = Process.pid

        # Run an initial beat
        Jobs.beat!

        # Schedule subsequent beats for every 5 seconds
        EventMachine.add_periodic_timer(5) { Jobs.beat! } #TODO: make interval configurable

        # Start a server
        EventMachine.start_unix_domain_server socket_path.to_s, Receiver
        logger.info "Listening on socket #{socket_path}"

        # Make sure other users can connect to the server
        socket_path.chmod 0777 #TODO: make configurable

        # Ensure the socket is destroyed when the server exits
        EventMachine.add_shutdown_hook { socket_path.delete }
      end

      def send(*args)
        ensure_running
        Sender.send *args
      end

      def shutdown(process = nil)
        process ||= self.process
        raise Exceptions::Fatal, 'Attempted to shut down server when no server is running' unless running?
        if process.pid == Process.pid
          EventMachine.next_tick do
            EventMachine.stop_event_loop
            Data.server_pid = nil
            logger.info 'Server has shut down'
          end
        else
          logger.info 'Server will shut down'
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
