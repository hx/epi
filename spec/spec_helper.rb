require 'pathname'
require 'fileutils'

SPEC_ROOT = Pathname File.expand_path('..', __FILE__)

ENV['EPI_HOME'] = SPEC_ROOT.join('.epi').to_s

require_relative '../lib/epi'


RSpec.configure do |config|

  config.around :each, with: :em do |ex|
    EM.run { ex.run.tap { EM.stop } }
  end


  config.before :suite do
    Epi.logger = Epi::ROOT.join('log/spec.log').to_s
    Epi.logger.level = Logger::DEBUG
  end

  config.after :each do
    FileUtils.rm_rf ENV['EPI_HOME']
    Epi::Data.reset!
    Epi::Jobs.reset!
    Epi::ProcessStatus.reset!
  end

end
