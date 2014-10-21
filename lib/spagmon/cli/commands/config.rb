module Spagmon
  module Cli
    module Commands
      class Config < Command

        def run
          case args.shift
            when 'add' then add
            else raise Exceptions::Fatal, 'Unknown config command, use [ add ]'
          end
        end

        private

        def add
          raise Exceptions::Fatal, 'No path given' unless args.first
          paths = args.map do |path|
            path = Pathname(path)
            path = Pathname('.').realpath.join(path) unless path.absolute?
            path.to_s
          end
          Spagmon::Server.send config: {add_paths: paths}
        end

      end
    end
  end
end
