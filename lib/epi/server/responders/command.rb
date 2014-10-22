module Epi
  module Server
    module Responders
      class Command < Responder

        attr_accessor :command, :arguments

        def run
          Cli::Command.run command, arguments
        end

      end
    end
  end
end
