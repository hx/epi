module Spagmon
  class JobDescription

    attr_accessor :name, :directory, :environment, :command, :processes,
                  :autostart, :stdout, :stderr, :user, :kill_timeout

    attr_reader :id

    def initialize(id)
      @id = id
      @handlers = {}
    end

    def reconfigure
      @handlers = {}
      yield self
    end

    def on(event, *args, &handler)
      (@handlers[event] ||= []) << {
          args: args,
          handler: handler
      }
    end

  end
end
