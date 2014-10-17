module Spagmon
  module Server
    module Responders
      class Shutdown < Responder

        attr_accessor :command, :arguments

        def run
          raise Exceptions::Shutdown
        end

      end
    end
  end
end
