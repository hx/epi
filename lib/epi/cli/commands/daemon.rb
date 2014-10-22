module Epi
  module Cli
    module Commands
      class Daemon < Command

        def run
          Epi::Daemon.run
          puts 'Daemon is running'
        end

      end
    end
  end
end
