module Spagmon
  module Server
    module Responders
      class Config < Responder

        attr_accessor :add_paths

        def run
          result = []
          configs = Data['configurations'] ||= {}
          add_paths.each do |path|
            if configs.key?(path)
              logger.warn "Tried to re-add config path: #{path}"
              result << "Config path already loaded: #{path}"
            else
              logger.info "Adding config path: #{path}"
              configs[path.to_s] ||= nil
              result << "Added config path: #{path}"
            end
          end if add_paths
          Data.save
          result.join ' '
        end

      end
    end
  end
end
