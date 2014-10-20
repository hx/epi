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
      @logger ||= Logger.new(ENV['SPAGMON_LOG'] || STDOUT).tap { |l| l.level = Logger::WARN }
    end

    def logger=(value)
      @logger = Logger === value ? value : Logger.new(value).tap { |l| l.level = Logger::INFO }
    end

    def root?
      @is_root = `whoami`.chomp == 'root' if @is_root.nil?
      @is_root
    end

  end

end
