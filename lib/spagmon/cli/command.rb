require 'active_support/inflector'

module Spagmon
  module Cli
    unless defined? Command

      class Command

        def self.run(command, args)
          const_name = command.camelize.to_sym
          if Commands.const_defined? const_name
            klass = Commands.const_get const_name
            return klass.new(args).run if Class === klass && klass < self
          end
          raise Exceptions::Fatal, 'Unknown command'
        end

        attr_reader :args

        def initialize(args)
          @args = args.freeze
        end

      end

      Dir[File.expand_path '../commands/*.rb', __FILE__].each { |f| require f }
    end
  end
end
