module Epi
  module Cli
    module Commands
      class Restart < Command
        include Concerns::Daemon

        def run
          need_root!
          need_daemon!
          Epi::Daemon.send(:stop_all) { shutdown { resume } }
        end

      end
    end
  end
end
