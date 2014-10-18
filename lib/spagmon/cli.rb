require_relative 'cli/command'

module Spagmon
  module Cli

    class << self

      def run(args)
        command = args.shift
        begin
          Command.run command, args
        rescue Exceptions::Fatal => error
          STDERR << error.message
          STDERR << "\n"
          EventMachine.stop_event_loop
        end
      end

    end

  end
end
