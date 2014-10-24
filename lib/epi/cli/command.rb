module Epi
  module Cli
    unless defined? Command

      class Command

        def self.run(command, args)
          const_name = command.camelize.to_sym
          if Commands.const_defined? const_name
            klass = Commands.const_get const_name
            return klass.new(args).run if Class === klass && klass < self
          end
          raise Exceptions::Fatal, "Unknown command. Run `epi help` for help."
        end

        attr_reader :args

        def initialize(args)
          @args = args
        end

        def need_root!
          process = Epi::Daemon.process
          raise Exceptions::Fatal, 'You need root privileges to manage this daemon' if
              process && process.was_alive? && process.root? && !Epi.root?
        end

      end

      Dir[File.expand_path '../commands/concerns/*.rb', __FILE__].each { |f| require f }
      Dir[File.expand_path '../commands/*.rb', __FILE__].each { |f| require f }
    end
  end
end
