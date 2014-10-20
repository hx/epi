# Spagmon

Keeps your workers alive.

## Installation

```
$ gem install spagmon
```

## Configuration

Example `config.spag`:

```ruby
job resque: 'Resque Workers' do |j|
  j.user = 'webapp'
  j.directory = File.expand_path('..', __FILE__)
  j.environment = {
      QUEUE: '*',
      TERM_CHILD: 1,
      PIDFILE: -> p { p.pidfile }
  }
  j.command = 'bundle exec rake resque:work'
  j.initial_processes = 2
  j.allowed_processes = 1..5
  j.stdout = nil
  j.stderr = '/var/log/worker_errors.log'
  j.kill_timeout = 3.seconds

  j.on(:touch, __FILE__) { |p| p.restart! }
  j.on(:memory, :gt, 350.megabytes) { |p| p.restart! }
end
```

Tell Spagmon to watch this config file:

```
$ spagmon config add config.spag
Added configuration file: /home/my_app/config.spag
```

## Behaviour

See what Spagmon is up to:

```
$ spagmon status
---
Running as: root
Since: Mon 20 Oct 2014 15:27:04
Jobs:
  Resque Workers [resque]:
    PID 40210:
      Since: Mon 20 Oct 2014 15:31:20
      CPU: 0.0%
      Memory: 0.3%
    PID 40213 [dying]:
      Since: Mon 20 Oct 2014 15:31:21
      CPU: 0.0%
      Memory: 0.2%  
```

Start/stop workers:

```
$ spagmon job resque more
Increasing 'Resque Workers' processes by 1 (from 2 to 3)
$ spagmon job resque 2 less
Decreasing 'Resque Workers' processes by 2 (from 3 to 1)
$ spagmon job resque 4
Increasing 'Resque Workers' processes by 3 (from 1 to 4)
$ spagmon job resque pause
Decreasing 'Resque Workers' processes by 4 (from 4 to 0)
$ spagmon job resque resume
Increasing 'Resque Workers' processes by 4 (from 0 to 4)
$ spagmon job resque max
Increasing 'Resque Workers' processes by 1 (from 4 to 5)
$ spagmon job resque restart
Replacing 5 'Resque Workers' processes
```

Control the Spagmon daemon, and all its managed processes:

```
$ spagmon stop
Stopping 5 workers ...
Shutting down ...
$ spagmon start
Starting 5 workers ...
$ spagmon restart
Stopping 5 workers ...
Shutting down ...
Starting 5 workers ...
```

Config files will be reloaded whenever they change.

## Running as other users

You can only configure jobs to run as other users if the Spagmon daemon runs as root.

The daemon is started the first time you run the `spagmon` command, as whatever user ran it. If `spagmon` is ever run by `root`, the original user's daemon will be replaced by a daemon owned by `root`. Once that's happened, Spagmon will complain if you try to start or stop the daemon as any other user.

Spagmon recognises the history of its daemon running as root by the presence of data in `/etc/spagmon`. You can force it to use a particular user's data instead by setting the `SPAGMON_HOME` environment variable to, for example, `~/.spagmon`.