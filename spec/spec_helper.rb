require 'pathname'
require 'fileutils'

require_relative '../lib/spagmon'

SPEC_ROOT = Pathname File.expand_path('..', __FILE__)

RSpec.configure do |config|
  config.before :each do
    FileUtils.rm_rf SPEC_ROOT + '.spagmon'
  end
end
