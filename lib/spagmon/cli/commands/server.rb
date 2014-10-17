require 'eventmachine'

module Spagmon
  module Cli
    module Commands
      class Server < Command

        def run
          case args.first
            when nil, 'start' then startup
            when 'stop' then shutdown
            else raise Exceptions::Fatal, 'Unknown server command, use [ start | stop | restart ]'
          end
        end

        private

        def startup
          Spagmon::Server.run
        end

        def shutdown
          Spagmon::Server.send :shutdown
          puts 'Server has shut down'
        end

      end
    end
  end
end
