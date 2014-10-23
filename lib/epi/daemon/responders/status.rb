require 'yaml'

module Epi
  module Daemon
    module Responders
      # noinspection RubyStringKeysInHashInspection
      class Status < Responder

        def run
          Jobs.beat!
          YAML.dump stats
        end

        private

        def stats
          {
              'Running as' => `whoami`.chomp,
              'Since' => Daemon.start_time.strftime('%c'),
              'Jobs' => jobs
          }
        end

        def jobs
          all = Jobs.map { |id, j| ["#{j.job_description.name} [#{id}]", job(j)] }.to_h
          all.count > 0 ? all : 'none'
        end

        def job(j)
          all = processes(j.pids).merge processes(j.dying_pids, 'dying')
          all.count > 0 ? all : 'paused'
        end

        def processes(pids, state = nil)
          pids.values.map do |pid|
            name = 'PID ' << pid.to_s
            name << " [#{state}]" if state
            [name, process(pid)]
          end.to_h
        end

        def process(pid)
          rp = ProcessStatus[pid]
          {
              'Since' => rp.started_at.strftime('%c'),
              'CPU' => '%0.1f%' % rp.cpu_percentage,
              'Memory' => '%0.1f%' % rp.memory_percentage
          }
        end

      end
    end
  end
end
