module Spagmon
  module Server
    module Responders
      class Config < Responder

        attr_accessor :add_paths

        def run
          result = []
          configs = Data.configuration_paths
          add_paths.each do |path|
            path = path.to_s
            if configs.include?(path)
              logger.warn "Tried to re-add config path: #{path}"
              result << "Config path already loaded: #{path}"
            else
              logger.info "Adding config path: #{path}"
              configs << path
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
