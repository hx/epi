module Spagmon
  module Cli
    module Commands
      class Status < Command

        def run
          Spagmon::Server.send :status
        end

      end
    end
  end
end