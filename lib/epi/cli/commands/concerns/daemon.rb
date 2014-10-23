module Epi
  module Cli
    module Concerns
      module Daemon

        protected

        def need_daemon!
          raise Exceptions::Fatal, 'No daemon is running' unless Epi::Daemon.running?
        end

        def need_no_daemon!
          raise Exceptions::Fatal, 'Daemon is already running' if Epi::Daemon.running?
        end

        def shutdown(&callback)
          Epi::Daemon.send :shutdown, &callback
          puts 'Shutting down ...'
        end

        def resume(&callback)
          begin
            Timeout::timeout(5) { sleep 0.05 while Epi::Daemon.socket_path.exist? }
          rescue Timeout::Error
            raise Exceptions::Fatal, 'Daemon failed to stop after 5 seconds'
          end
          Epi::Daemon.send :start, &callback
        end

      end
    end
  end
end