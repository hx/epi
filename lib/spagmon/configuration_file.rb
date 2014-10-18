require 'forwardable'
require 'pathname'
require 'digest'

module Spagmon
  class ConfigurationFile
    extend Forwardable
    include Exceptions

    def self.from_hash(hash)

    end

    attr_reader :path

    delegate [:exist?, :binread] => :path

    def initialize(path)
      @jobs = {}
      @path = Pathname path
    end

    def logger
      Spagmon.logger
    end

    def to_h

    end

    def read
      return unless exist? && changed?
      logger.info "Reading configuration file #{path}"
      data = binread
      begin
        instance_eval data, path.to_s
        @last_digest = Digest::MD5.digest(data)
      rescue => error
        raise InvalidConfigurationFile.new("Unhandled exception of type #{error.class.name}", error)
      end
    end

    def changed?
      Digest::MD5.digest(binread) != @last_digest
    end

    def job(id_and_name, &block)
      raise InvalidConfigurationFile, 'Improper use of "job"' unless
          Hash === id_and_name &&
          id_and_name.count == 1 &&
          Symbol === id_and_name.keys.first &&
          String === id_and_name.values.first &&
          block.respond_to?(:call) &&
          block.respond_to?(:arity) &&
          block.arity >= 1
      id, name = id_and_name.first
      job = @jobs[id] ||= JobDescription.new(id)
      job.name = name
      job.reconfigure &block
    end

  end
end
