module Epi
  module Cli
    module Commands
      class Status < Command

        def run
          if Epi::Daemon.running?
            Epi::Daemon.send :status
          else
            Epi::Daemon.send(:start) { Epi::Daemon.send :status }
          end
        end

      end
    end
  end
end
