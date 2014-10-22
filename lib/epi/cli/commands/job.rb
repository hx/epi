module Epi
  module Cli
    module Commands
      class Job < Command

        def run
          id = args.shift
          raise Exceptions::Fatal, 'No job ID given' if id.nil? || id.empty?
          instruction = args.join(' ').strip
          raise Exceptions::Fatal, 'No instruction given' if instruction.empty?
          raise Exceptions::Fatal, 'Invalid instruction' unless
              instruction =~ /^((\d+ )?(more|less)|\d+|pause|resume|reset|max|min|restart)$/
          Epi::Server.send job: {id: id, instruction: instruction}
        end

      end
    end
  end
end
