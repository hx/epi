module Epi
  module Cli
    module Commands
      class Status < Command

        def run
          Epi::Server.send :status
        end

      end
    end
  end
end