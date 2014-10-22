module Epi
  module Cli
    module Commands
      class Stop < Command

        def run
          need_root!
          raise Exceptions::Fatal, 'No daemon is running' unless Epi::Daemon.running?
          Epi::Daemon.send(:stop_all) { shutdown }
        end

        private

        def shutdown
          Epi::Daemon.send :shutdown
          puts 'Shutting down ...'
        end

      end
    end
  end
end
