require 'pathname'
require 'logger'
require 'shellwords'

require 'epi/core_ext'
require 'epi/exceptions'
require 'epi/version'
require 'epi/cli'
require 'epi/daemon'
require 'epi/data'
require 'epi/process_status'
require 'epi/running_process'
require 'epi/job'
require 'epi/jobs'
require 'epi/configuration_file'
require 'epi/job_description'
require 'epi/launch'

module Epi
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
      Logger.new(target || ENV['EPI_LOG'] || STDOUT).tap do |logger|
        logger.level = Logger::Severity::WARN
        level = ENV['EPI_LOG_LEVEL']
        if level
          level = level.upcase
          logger.level = Logger::Severity.const_get(level) if Logger::Severity.const_defined? level
        end
      end
    end

  end

end
