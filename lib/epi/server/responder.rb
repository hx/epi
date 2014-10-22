module Epi
  module Server
    unless defined? Responder
      class Responder
        include Exceptions

        # Runs a responder by name.
        #
        # @param receiver [Receiver] The receiver that is running the responder
        # @param name [String] Name of the responder to invoke, e.g. 'command'
        # @param data [Hash] Data included in the message, to be extracted onto the responder before it is run
        def self.run(receiver, name, data)
          klass_name = name.camelize.to_sym
          klass = Responders.const_defined?(klass_name) && Responders.const_get(klass_name)
          raise Fatal, 'Unknown message type' unless Class === klass && klass < Responder
          responder = klass.new(receiver)
          data.each { |key, value| responder.__send__ :"#{key}=", value }
          responder.run
        end

        attr_reader :receiver

        def logger
          Epi.logger
        end

        def initialize(receiver)
          @receiver = receiver
        end

        def run
          raise NotImplementedError, "You need to define #run for class #{self.class.name}"
        end

        def puts(text)
          receiver.puts text
        end

      end

      Dir[File.expand_path '../responders/*.rb', __FILE__].each { |f| require f }
    end
  end
end
