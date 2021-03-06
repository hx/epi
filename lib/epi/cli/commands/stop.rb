module Epi
  module Cli
    module Commands
      class Stop < Command
        include Concerns::Daemon

        def run
          need_root!
          need_daemon!
          Epi::Daemon.send(:stop_all) { shutdown }
        end

      end
    end
  end
end
