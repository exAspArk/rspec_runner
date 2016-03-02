require 'drb/drb'
require 'rspec_runner/configuration'

module RspecRunner
  class Client
    class << self
      def execute(*args)
        DRb.start_service
        try_count = 0
        print 'Connecting... '

        while try_count < RspecRunner.configuration.client_timeout
          begin
            uri = fetch_uri
            raise DRb::DRbConnError unless uri

            runner = DRbObject.new_with_uri(uri)
            print 'running... '
            runner.execute(*args)
            puts 'done!'
            return true
          rescue DRb::DRbConnError
            try_count += 1
            sleep(1)
          end
        end

        puts 'Server is down :('
      end

      private

      def fetch_uri
        return unless File.exist?(RspecRunner.configuration.uri_filepath)
        result = File.read(RspecRunner.configuration.uri_filepath)
        result unless result.empty?
      end
    end
  end
end
