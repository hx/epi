require 'eventmachine'

require_relative 'daemon/sender'
require_relative 'daemon/receiver'
require_relative 'daemon/responder'

module Epi
  module Daemon

    class << self

      attr_reader :start_time

      def logger
        Epi.logger
      end

      def ensure_running
        should_run_as_root = Data.root?

        if running? && should_run_as_root && !process.root?
          logger.info "Daemon needs to run as root, but is running as #{process.user}"
          shutdown
        end

        unless running?
          if should_run_as_root && !Epi.root?
            raise Exceptions::Fatal, 'Found root data but not running as root. Either run again as root, ' +
                'or specify EPI_HOME as a directory other than /etc/epi'
          end

          logger.info 'Starting daemon'
          Epi.launch [$0, 'daemon'],
                     stdout: Data.home + 'daemon.log',
                     stderr: Data.home + 'daemon_errors.log'

          begin
            Timeout::timeout(5) { sleep 0.05 until socket_path.exist? }
          rescue Timeout::Error
            raise Exceptions::Fatal, 'Daemon not started after 5 seconds'
          end unless socket_path.exist?
        end
      end

      def socket_path
        Data.home + 'socket'
      end

      def run
        raise Exceptions::Fatal, 'Daemon already running' if running?

        # Save the daemon PID
        Data.daemon_pid = Process.pid

        # Run an initial beat
        Jobs.beat!

        # Start a daemon
        EventMachine.start_unix_domain_server socket_path.to_s, Receiver
        logger.info "Listening on socket #{socket_path}"

        # Make sure other users can connect to the daemon
        socket_path.chmod 0777 #TODO: make configurable

        # Ensure the socket is destroyed when the daemon exits
        EventMachine.add_shutdown_hook { socket_path.delete }

        @start_time = Time.now
      end

      def send(*args, &callback)
        ensure_running
        Sender.send *args, &callback
      end

      def shutdown(process = nil)
        raise Exceptions::Fatal, 'Attempted to shut down daemon when no daemon is running' unless running?
        if (process || self.process).pid == Process.pid
          EventMachine.next_tick do
            EventMachine.stop_event_loop
            Data.daemon_pid = nil
            logger.info 'Daemon has shut down'
          end
        else
          logger.info 'Daemon will shut down'
          send :shutdown
        end
      end

      def running?
        process && process.was_alive?
      end

      def process
        daemon_pid = Data.daemon_pid
        @process = nil if @process && @process.pid != daemon_pid
        @process ||= daemon_pid && RunningProcess.new(daemon_pid)
      end

    end

  end
end
