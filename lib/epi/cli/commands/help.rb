module Epi
  module Cli
    module Commands
      # noinspection RubyStringKeysInHashInspection
      class Help < Command

        def run
          puts doc
          EM.stop
        end

        private

        def doc
<<-EOF
Epinephrine v#{Epi::VERSION} (c) 2014 Neil E. Pearson
Licensed under the Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0
See https://github.com/hx/epi for complete documentation

Usage:
  #{$0} command [etc...]

Commands:
#{commands}
Env vars:
  EPI_LOG        Path to which logs should be written
  EPI_LOG_LEVEL  Logging severity (debug, info, warn, error, fatal)
  EPI_INTERVAL   Delay in seconds between process status checks
  EPI_HOME       Directory in which Epi should store state data
EOF
        end

        def commands
          all =
          {
              'help' => 'Show this screen',

              'config add PATH' => 'Start watching the config file at PATH',
              'config remove PATH' => 'Stop watching the config file at PATH',

              'job ID NUM' => 'Run NUM instances of ID job',
              'job ID [more|less]' => 'Run one more/less instances of ID job',
              'job ID NUM [more|less]' => 'Run NUM more/less instances of ID job',
              'job ID pause' => 'Stop all instances of ID job',
              'job ID reset' => 'Run the initial number of ID job instances',
              'job ID max' => 'Run the maximum allowed number of ID job instances',
              'job ID min' => 'Run the minimum allowed number of ID job instances',
              'job ID restart' => 'Replace all instances of ID job with new ones',

              'status' => 'Show details of running/dying instances',

              'start' => 'Start the Epi daemon, and all expected jobs',
              'stop' => 'Stop the Epi daemon, and all running jobs',
              'restart' => 'Restart the Epi daemon, and all running jobs'

          }
          max_key_width = all.keys.map(&:length).max
          all.map do |cmd, desc|
            "  #{cmd} %s #{desc}\n" % (' ' * (max_key_width - cmd.length))
          end.join ''
        end

      end
    end
  end
end
