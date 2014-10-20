module Spagmon
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

    # Prevent hang-up
    cmd = 'nohup ' << cmd

    # Include the working directory
    cmd = "(cd #{Shellwords.escape cwd} && #{cmd})" if cwd

    # Include `su` command if a user is given
    cmd = "su #{user} -c #{cmd}" if user

    # STDOUT and STDERR redirection
    {:> => stdout, :'2>' => stderr}.each do |arrow, dest|
      cmd << " #{arrow} #{dest || '/dev/null'}" unless TrueClass === dest
    end

    # Run in background, and return PID of backgrounded process
    cmd << ' & echo $!'

    # Convert environment variables to strings, and merge them with the current environment
    env = ENV.to_h.merge(env).map { |k, v| [k.to_s, v.to_s] }.to_h

    logger.debug "Launching #{cmd}"

    # Run the command and read the resulting PID from its STDOUT
    IO.popen(env, cmd).read.to_i
  end
end
