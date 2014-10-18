require 'time'

module Spagmon
  # noinspection RubyTooManyInstanceVariablesInspection
  class RunningProcess

    DEFAULT_TIMEOUT = 20

    @users = {}

    class << self

      def user_name(uid)
        @users[uid.to_i] ||= `id -un #{uid}`.chomp
      end

      def group_name(gid)
        groups[gid.to_i]
      end

      private

      def groups
        @groups ||= read_groups
      end

      def read_groups
        {}.tap do |result|
          File.readlines('/etc/group').each do |line|
            result[$2.to_i] = $1 if line =~ /^([^:]+):[^:]+:(-?\d+):/
          end
        end
      end

    end

    PS_FORMAT = 'pid,%cpu,%mem,rss,vsz,lstart,uid,gid,command'

    attr_reader :pid

    def logger
      Spagmon.logger
    end

    def initialize(pid, ps_line = nil)
      @pid = pid
      @ps_line = ps_line
      @props = {}
      reload! unless ps_line
    end

    def reload!
      @props = {}
      @parts = nil
      @ps_line = `ps -p #{pid} -o #{PS_FORMAT}`.lines[1]
    end

    # Returns `true` if the process was running when this instance was created
    def was_alive?
      !@ps_line.nil?
    end

    # CPU usage as a percentage
    # @return [Float]
    def cpu_percentage
      @cpu_percentage ||= parts[1].to_f
    end

    # Physical memory usage as a percentage
    # @return [Float]
    def memory_percentage
      @memory_percentage ||= parts[2].to_f
    end

    # Physical memory usage in bytes (rounded to the nearest kilobyte)
    # @return [Fixnum]
    def physical_memory
      @physical_memory ||= parts[3].to_i * 1024
    end

    # Virtual memory usage in bytes (rounded to the nearest kilobyte)
    # @return [Fixnum]
    def virtual_memory
      @virtual_memory ||= parts[4].to_i * 1024
    end

    # Sum of {#physical_memory} and {#total_memory}
    # @return [Fixnum]
    def total_memory
      @total_memory ||= physical_memory + virtual_memory
    end

    # Time at which the process was started
    # @return [Time]
    def started_at
      @started_at ||= Time.parse parts[5..9].join ' '
    end

    # Name of the user that owns the process
    # @return [String]
    def user
      @user ||= self.class.user_name parts[10]
    end

    # Name of the group that owns the process
    # @return [String]
    def group
      @group ||= self.class.group_name parts[11]
    end

    # The command that was used to start the process, including its arguments
    # @return [String]
    def command
      @command ||= parts[12]
    end

    # Whether the process is root-owned
    # @return [TrueClass|FalseClass]
    def root?
      user == 'root'
    end

    # Kill a running process
    # @param timeout [TrueClass|FalseClass|Numeric] `true` to kill immediately (KILL),
    #   `false` to kill gracefully (TERM), or a number of seconds to wait between trying
    #   both (first TERM, then KILL).
    # @return [RunningProcess]
    def kill(timeout = DEFAULT_TIMEOUT)
      if Numeric == timeout
        begin
          logger.info "Will wait #{timeout} seconds for process to terminate gracefully"
          Timeout::timeout(timeout) { kill }
        rescue Timeout::Error
          kill true
        end
      else
        signal = timeout ? 'KILL' : 'TERM'
        logger.info "Sending #{signal} to process #{pid}"
        Process.kill signal, pid
        Process.waitpid pid
        logger.info "Process #{pid} terminated by signal #{signal}"
      end
      self
    end

    def kill!
      kill true
    end

    private

    def parts
      raise 'Tried to access details of a non-running process' unless String === @ps_line
      @parts ||= @ps_line.strip.split(/\s+/, 13)
    end

  end

end
