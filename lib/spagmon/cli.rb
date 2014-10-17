require_relative 'cli/command'

module Spagmon
  module Cli

    class << self

      def run(args)
        command = args.shift
        if root?
          puts Command.run command, args
        else
          Server::Sender.send command: {command: command, arguments: args}
        end
      end

      private

      def root?
        @is_root = `whoami`.chomp == 'root' if @is_root.nil?
        @is_root
      end

    end

  end
end
