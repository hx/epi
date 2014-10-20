#!/usr/bin/env ruby
STDOUT.sync = true
STDERR.sync = true
loop do
  STDERR << '!'
  5.times do
    STDOUT << '.'
    sleep 0.1
  end
end
