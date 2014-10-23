module Epi
  module Cli
    module Commands
      class Start < Command
        include Concerns::Daemon

        def run
          need_no_daemon!
          Epi::Daemon.send :start
        end

      end
    end
  end
end
