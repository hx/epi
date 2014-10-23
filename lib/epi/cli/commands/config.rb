module Epi
  module Cli
    module Commands
      class Config < Command

        def run
          case args.shift
            when 'add' then add
            when 'remove' then remove
            else raise Exceptions::Fatal, 'Unknown config command, use [ add | remove ]'
          end
        end

        private

        def add
          Epi::Daemon.send config: {add_paths: paths}
        end

        def remove
          Epi::Daemon.send config: {remove_paths: paths}
        end

        def paths
          raise Exceptions::Fatal, 'No path given' unless args.first
          @paths ||= args.map do |path|
            path = Pathname(path)
            path = Pathname('.').realpath.join(path) unless path.absolute?
            path.to_s
          end
        end

      end
    end
  end
end
