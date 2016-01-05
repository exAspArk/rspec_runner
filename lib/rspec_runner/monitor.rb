require 'rspec_runner/server'
require 'rspec_runner/watcher'

module RspecRunner
  class Monitor
    class << self
      def run
        start

        at_exit { die }

        watcher_thread = Watcher.run do |changes|
          puts 'Restarting...'
          restart
        end

        watcher_thread.join
        sleep 10_000 while true # :(
      end

      private

      def start
        @pid = fork { RspecRunner::Server.run }
        Process.detach(@pid) # so if the child exits, it dies
      end

      def stop
        if @pid && @pid != 0
          # TODO: try to kill without -9
          send_signal('KILL')
          RspecRunner::Server.stop
        end
      end

      def send_signal(signal)
        Process.kill(signal, @pid)
      end

      def die
        stop
        exit 0
      end

      def restart
        stop
        start
      end
    end
  end
end
