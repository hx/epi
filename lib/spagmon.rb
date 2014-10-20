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

  # Run a system command in the background, and allow it to keep running
  # after Ruby has exited.
  # @param command [String|Array] The command to run, either as a pre-escaped string,
  #   or an array of non-escaped strings (a command and zero or more arguments).
  # @param env [Hash] Environment variables to be passed to the command, in addition
  #   to those inherited from the current environment
  # @param user [String|NilClass] If supplied, command will be run through `su` as
  #   this user.
  # @param cwd [String|NilClass] If supplied, command will be run from this
  #   directory.
  # @param stdout [String|TrueClass|FalseClass|NilClass] Where to redirect standard
  #   output; either a file path, or `true` for no redirection, or `false`/`nil` to
  #   redirect to `/dev/null`
  # @param stderr [String|TrueClass|FalseClass|NilClass] Where to redirect standard
  #   error; either a file path, or `true` for no redirection, or `false`/`nil` to
  #   redirect to `/dev/null`
  # @return [Fixnum] The PID of the started process
  def self.launch(command, env: {}, user: nil, cwd: nil, stdout: true, stderr: true)

    # The main command and its arguments
    if String === command

      # Pre-escaped string
      cmd = command.dup
    else

      # Command and arguments that need to be escaped
      cmd = command.map { |part| Shellwords.escape part }.join ' '
    end

    # Include the working directory
    cmd = "(cd #{Shellwords.escape cwd} && #{cmd})" if cwd

    # Include `su` command if a user is given
    cmd = "su #{user} -c #{cmd}" if user

    # Prevent hang-up
    cmd = 'nohup ' << cmd

    # STDOUT and STDERR redirection
    {:> => stdout, :'2>' => stderr}.each do |arrow, dest|
      cmd << " #{arrow} #{dest || '/dev/null'}" unless TrueClass === dest
    end

    # Run in background, and return PID of backgrounded process
    cmd << ' & echo $!'

    # Run the command and read the resulting PID from its STDOUT
    IO.popen(ENV.merge(env), cmd).read.to_i
  end
end
