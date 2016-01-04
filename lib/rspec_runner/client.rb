require 'drb/drb'

module RspecRunner
  class Client
    # TODO: move to config
    DRB_URI = 'druby://localhost:8787'.freeze
    TIMEOUT = 10 # seconds

    class << self
      def execute(*args)
        DRb.start_service
        runner = DRbObject.new_with_uri(DRB_URI)

        try_count = 0
        print 'Running tests... '
        while try_count <= TIMEOUT
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
