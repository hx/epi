require 'pathname'
require 'fileutils'

SPEC_ROOT = Pathname File.expand_path('..', __FILE__)

ENV['SPAGMON_HOME'] = SPEC_ROOT.join('.spagmon').to_s

require_relative '../lib/spagmon'


RSpec.configure do |config|

  config.before :suite do
    Spagmon.logger = Spagmon::ROOT.join('log/spec.log').to_s
    Spagmon.logger.level = Logger::DEBUG
  end

  config.after :each do
    FileUtils.rm_rf ENV['SPAGMON_HOME']
    Spagmon::Data.reset!
    Spagmon::Jobs.reset!
    Spagmon::ProcessStatus.reset!
  end

end
