require 'open3'
require 'rspec_runner/watcher'

module RspecRunner
  class Runner
    CMD = 'bundle exec rspec_runner start'.freeze

    class << self
      def run
        start

        watcher = Watcher.run do |changes|
          puts 'Restarting...'
          restart
        end

        watcher.join
        sleep 10000 while true # :(
      end

      private

      # TOOD: handle errors, get rid of zombie
      def start
        @pid = fork { exec(CMD) }
      end

      def stop
        Process.kill('KILL', @pid)
      end

      def restart
        stop
        start
      end
    end
  end
end
