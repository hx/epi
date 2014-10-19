require 'pathname'
require 'logger'

require 'spagmon/core_ext'
require 'spagmon/exceptions'
require 'spagmon/version'
require 'spagmon/cli'
require 'spagmon/server'
require 'spagmon/data'
require 'spagmon/process_status'
require 'spagmon/running_process'
require 'spagmon/jobs'
require 'spagmon/configuration_file'
require 'spagmon/job_description'

module Spagmon
  ROOT = Pathname File.expand_path('../..', __FILE__)

  HOST = '127.0.0.1'
  PORT = 29484

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.root?
    @is_root = `whoami`.chomp == 'root' if @is_root.nil?
    @is_root
  end
end
