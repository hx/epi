require 'pathname'
require 'logger'
require 'shellwords'

require 'spagmon/core_ext'
require 'spagmon/exceptions'
require 'spagmon/version'
require 'spagmon/cli'
require 'spagmon/server'
require 'spagmon/data'
require 'spagmon/process_status'
require 'spagmon/running_process'
require 'spagmon/job'
require 'spagmon/jobs'
require 'spagmon/configuration_file'
require 'spagmon/job_description'
require 'spagmon/launch'

module Spagmon
  ROOT = Pathname File.expand_path('../..', __FILE__)

  class << self

    def logger
      @logger ||= make_logger
    end

    def logger=(value)
      @logger = Logger === value ? value : make_logger(value)
    end

    def root?
      @is_root = `whoami`.chomp == 'root' if @is_root.nil?
      @is_root
    end

    private

    def make_logger(target = nil)
      Logger.new(target || ENV['SPAGMON_LOG'] || STDOUT).tap do |logger|
        logger.level = Logger::Severity::WARN
        level = ENV['SPAGMON_LOG_LEVEL']
        if level
          level = level.upcase
          logger.level = Logger::Severity.const_get(level) if Logger::Severity.const_defined? level
        end
      end
    end

  end

end
