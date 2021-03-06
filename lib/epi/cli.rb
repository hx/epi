require_relative 'cli/command'

module Epi
  module Cli

    class << self

      def run(args)
        command = args.shift || 'help' # The default command
        begin
          Command.run command.delete('-'), args
        rescue Exceptions::Fatal => error
          STDERR << error.message
          STDERR << "\n"
          EventMachine.stop_event_loop
        end
      end

    end

  end
end
