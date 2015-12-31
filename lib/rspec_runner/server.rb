require 'drb/drb'

module RspecRunner
  class Server
    # TODO: move to config
    DRB_URI = 'druby://localhost:8787'.freeze

    class << self
      def run
        require 'rspec'
        DRb.start_service(DRB_URI, self)

        $LOAD_PATH.unshift File.expand_path("#{Dir.pwd}/spec")
        require 'spec_helper.rb'
        puts 'Server started!'

        DRb.thread.join
      end

      def execute(path)
        RSpec::Core::Runner.run(filepaths(path))
      ensure
        reset_rspec!
      end

      private

      def filepaths(path)
        multiple_files?(path) ? Dir.glob(path) : [path]
      end

      def multiple_files?(path)
        path.include?('*'.freeze)
      end

      def reset_rspec!
        world = RSpec.world
        configuration = RSpec.configuration

        world.reset
        world.filtered_examples.clear
        world.instance_variable_set(:@example_group_counts_by_spec_file, Hash.new(0))
        configuration.reset
        configuration.reset_filters if configuration.respond_to?(:reset_filters)
        configuration.files_to_run = []
        configuration.files_or_directories_to_run = []

        if configuration.respond_to?(:loaded_spec_files) && set = configuration.loaded_spec_files
          set.each { |k| set.delete(k) }
        end
      end
    end
  end
end
