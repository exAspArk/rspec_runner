require 'rspec_runner/server'
require 'rspec_runner/watcher'

module RspecRunner
  class Monitor
    class << self
      def start
        RspecRunner::Server.start

        at_exit { stop }

        watcher_thread = Watcher.start do |changes|
          puts 'Restarting...'
          RspecRunner::Server.restart
        end

        watcher_thread.join
        sleep 10_000 while true # :(
      end

      private

      def stop
        RspecRunner::Server.stop
        exit 0
      end
    end
  end
end
