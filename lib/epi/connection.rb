require 'eventmachine'

module Epi
  class Connection < EventMachine::Connection
    include EventMachine::Protocols::ObjectProtocol
  end
end
