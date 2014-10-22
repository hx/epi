module Epi
  module Cli
    module Commands
      class Server < Command

        def run
          process = Epi::Server.process
          raise Exceptions::Fatal, 'You need root privileges to manage this server' if
              process && process.was_alive? && process.root? && !Epi.root?
          case args.first
            when nil, 'start' then startup
            when 'run' then run_server
            when 'stop' then shutdown
            else raise Exceptions::Fatal, 'Unknown server command, use [ start | stop | restart ]'
          end
        end

        private

        def startup
          Epi::Server.ensure_running
          puts 'Server is running'
        end

        def shutdown
          Epi::Server.shutdown
          puts 'Server has shut down'
        end

        def run_server
          Epi::Server.run
          puts 'Server is running'
        end

      end
    end
  end
end
