require_relative 'cli/command'

module Spagmon
  module Cli

    class << self

      def run(args)
        command = args.shift
        if root?
          puts Command.run command, args
        else
          Spagmon.perish 'Please run this command as root.' if command == 'simmer'
          EventMachine.run do
            EventMachine.connect HOST, PORT, Pray, command, args
          end
        end
      end

      private

      def root?
        @is_root ||= `whoami`.chomp == 'root'
      end

    end

  end
end
