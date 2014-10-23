require 'pathname'
require 'logger'
require 'shellwords'

require 'epi/core_ext'
require 'epi/logging'
require 'epi/exceptions'
require 'epi/version'
require 'epi/cli'
require 'epi/connection'
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

    def root?
      @is_root = `whoami`.chomp == 'root' if @is_root.nil?
      @is_root
    end

  end

end
