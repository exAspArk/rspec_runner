require 'listen'
require 'rspec_runner/configuration'

module RspecRunner
  class Watcher
    class << self
      def start(&block)
        if @thread then
          raise RuntimeError, "already started"
        end

        @thread = Thread.new do
          @listener = Listen.to(
            *RspecRunner.configuration.watch_directories,
            only: RspecRunner.configuration.watch_pattern,
            ignore: RspecRunner.configuration.ignore_pattern,
            wait_for_delay: 1
          ) do |modified, added, removed|
            if((modified.size + added.size + removed.size) > 0)
              block.call(modified: modified, added: added, removed: removed)
            end
          end
          @listener.start
          puts 'Watcher started!'
        end

        sleep(0.1) until @listener

        at_exit { stop }

        @thread
      end

      private

      def stop
        @thread.wakeup rescue ThreadError
        begin
          @listener.stop
        rescue => e
          puts "#{e.class}: #{e.message} stopping listener"
        end
        @thread.kill rescue ThreadError
      end
    end
  end
end
