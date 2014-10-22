module Epi
  module Daemon
    module Responders
      class Job < Responder

        attr_accessor :id, :instruction

        def run
          Jobs.beat!
          raise Exceptions::Fatal, 'Unknown job ID' unless Epi::Job === job
          case instruction
            when /^\d+$/ then set instruction.to_i
            when /^(\d+ )?(more|less)$/ then __send__ $2, ($1 || 1).to_i
            else __send__ instruction
          end
        end

        private

        def job
          @job ||= Jobs[id]
        end

        def set(count, validate = true)
          allowed = job.allowed_processes
          raise Exceptions::Fatal, "Requested count #{count} is outside allowed range #{allowed}" unless !validate || allowed === count
          original = job.expected_count
          raise Exceptions::Fatal, "Already running #{count} process#{count != 1 ? 'es' : ''}" unless !validate || original != count
          job.expected_count = count
          job.sync!
          "#{count < original ? 'De' : 'In'}creasing '#{job.name}' processes by #{(original - count).abs} (from #{original} to #{count})"
        end

        def more(increase)
          set job.expected_count + increase
        end

        def less(decrease)
          set job.expected_count - decrease
        end

        def max
          set job.allowed_processes.max
        end

        def min
          set job.allowed_processes.min
        end

        def pause
          set 0
        end

        def resume
          set job.job_description.initial_processes
        end
        alias_method :reset, :resume

        def restart
          count = job.expected_count
          raise Exceptions::Fatal, 'This job has no processes to restart' if count == 0
          set 0, false
          set count
          "Replacing #{count} '#{job.name}' process#{count != 1 ? 'es' : ''}"
        end

      end
    end
  end
end
