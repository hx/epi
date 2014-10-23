module Epi
  module Daemon
    module Responders
      class Config < Responder

        attr_accessor :add_paths, :remove_paths

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
          remove_paths.each do |path|
            path = path.to_s
            if configs.include?(path)
              logger.info "Removing config path: #{path}"
              # TODO: clean up any junk the config file may have left
              configs.delete path
              result << "Removed config path: #{path}"
            else
              logger.warn "Tried to remove unknown config path: #{path}"
              result << "Config path not loaded: #{path}"
            end
          end if remove_paths
          Data.save
          Jobs.beat!
          result.join ' '
        end

      end
    end
  end
end
