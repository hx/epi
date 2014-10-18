require_relative 'cli/command'

module Spagmon
  module Cli
    include Spagmon

    class << self

      def run(args)
        command = args.shift
        if root?
          puts Command.run command, args
        else
          Server::Sender.send command: {command: command, arguments: args}
        end
      end

    end

  end
end
