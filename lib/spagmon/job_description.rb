require 'shellwords'
require 'securerandom'

module Spagmon
  class JobDescription

    def self.property(method, default = nil, &validator)
      define_method method do
        @props.key?(method) ? @props[method] : default
      end
      define_method :"#{method}=" do |value|
        if validator
          result = validator.call(value)
          raise Exceptions::Fatal, "Invalid value '#{value}' of type #{value.class.name} for #{method}: #{result}" if result
        end
        @props[method] = value
      end
    end

    property :name do |value|
      'Must be a non-blank string' unless String === value && !value.strip.empty?
    end

    property :directory do |value|
      'Must be a valid relative or absolute directory path' unless String === value && value =~ /\A[^\0]+\z/
    end

    property :environment, {} do |value|
      'Must be a hash' unless Hash === value
    end

    property :command do |value|
      'Must be a non-blank string' unless String === value && !value.strip.empty?
    end

    property :initial_processes, 1 do |value|
      'Must be a non-negative integer' unless Fixnum === value && value >= 0
    end

    property :allowed_processes, 0..10 do |value|
      'Must be a range including a positive integer, and no negatives' unless
          Range === value && value.max >= 1 && value.min >= 0
    end

    %i[stdout stderr].each do |pipe|
      property pipe do |value|
        'Must be a path to a file descriptor' unless String === value && value =~ /\A[^\0]+\z/
      end
    end

    property :user do |value|
      'Must be a non-blank string' unless String === value && !value.strip.empty?
    end

    property :kill_timeout, 20 do |value|
      'Must be a non-negative number' unless value.is_a?(Numeric) && value >= 0
    end

    attr_reader :id

    def initialize(id)
      @id = id
      @handlers = {}
      @props = {}
    end

    def launch
      proc_id = generate_id
      opts = {
          cwd: directory,
          user: user,
          env: {PIDFILE: pid_path(proc_id)}.merge(environment || {}),
          stdout: stdout,
          stderr: stderr
      }
      pid = Spagmon.launch command, **opts
      [proc_id, pid]
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

    def pid_key(proc_id)
      "pids/#{id}/#{proc_id}.pid"
    end

    def pid_path(proc_id)
      Data.home + pid_key(proc_id)
    end

    private

    def generate_id
      SecureRandom.hex 4
    end

  end
end
