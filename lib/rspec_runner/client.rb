require 'drb/drb'
require 'rspec_runner/configuration'

module RspecRunner
  class Client
    class << self
      def execute(*args)
        DRb.start_service
        runner = DRbObject.new_with_uri(RspecRunner.configuration.uri)

        try_count = 0
        print 'Running tests... '
        while try_count <= RspecRunner.configuration.client_timeout
          begin
            runner.execute(*args)
            puts 'done!'
            return true
          rescue DRb::DRbConnError
            try_count += 1
            sleep(1)
          end
        end

        puts 'Server is down'
      end
    end
  end
end
