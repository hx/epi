require 'pathname'
require 'logger'

require 'spagmon/version'
require 'spagmon/cli'
require 'spagmon/pot'
require 'spagmon/stir'
require 'spagmon/pray'

module Spagmon
  ROOT = Pathname File.expand_path('../..', __FILE__)

  HOST = '127.0.0.1'
  PORT = 29484

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.perish(why)
    STDOUT << why
    STDOUT << "\n"
    exit 1
  end
end
