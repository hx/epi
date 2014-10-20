require 'shellwords'

module Spagmon
  class JobDescription

    [:name, :directory, :environment, :command, :initial_processes, :allowed_processes,
     :stdout, :stderr, :user, :kill_timeout].each do |method|
      define_method method do
        value = @props[method]
        value.respond_to?(:call) ? value.call : value
      end
      define_method("#{method}=") { |value| @props[method] = value }
    end

    attr_reader :id

    def initialize(id)
      @id = id
      @handlers = {}
      @props = {
          environment: {},
          kill_timeout: 20,
          initial_processes: 1,
          allowed_processes: 0..10
      }
    end

    def launch
      Spagmon.launch command, cwd: directory, user: user, env: environment, stdout: stdout, stderr: stderr
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
