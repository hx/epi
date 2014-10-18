require 'pathname'
require 'fileutils'

SPEC_ROOT = Pathname File.expand_path('..', __FILE__)

ENV['SPAGMON_HOME'] = SPEC_ROOT.join('.spagmon').to_s

require_relative '../lib/spagmon'


RSpec.configure do |config|
  config.before :each do
    FileUtils.rm_rf ENV['SPAGMON_HOME']
  end
end
