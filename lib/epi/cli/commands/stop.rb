module Epi
  module Cli
    module Commands
      class Stop < Command

        def run
          need_root!
          Epi::Daemon.shutdown
          puts 'Shutting down ...'
        end

      end
    end
  end
end
