require 'eventmachine'
require 'bson'

module Epi
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::ObjectProtocol

    def serializer
      Serializer
    end

    module Serializer

      def self.dump(obj)
        obj.to_bson
      end

      def self.load(bin)
        Hash.from_bson StringIO.new bin
      end

    end
  end
end
