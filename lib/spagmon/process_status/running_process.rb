require 'time'

module Spagmon
  class ProcessStatus
    # noinspection RubyTooManyInstanceVariablesInspection
    class RunningProcess

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
              if line =~ /^([^:]+):[^:]+:(-?\d+):/
                result[$2.to_i] = $1
              end
            end
          end
        end

      end

      PS_FORMAT = 'pid,%cpu,%mem,rss,vsz,lstart,uid,gid,command'

      attr_reader :pid

      def initialize(pid, ps_line)
        @pid = pid
        @ps_line = ps_line
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

      private

      def parts
        @parts ||= @ps_line.strip.split(/\s+/, 13)
      end

    end
  end
end
