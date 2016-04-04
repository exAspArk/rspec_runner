require 'socket'
require 'drb/drb'
require 'rspec_runner/configuration'

module RspecRunner
  class Server
    class << self
      def start
        create_uri_file

        puts 'Preloading gems...'
        require 'rubygems'
        require 'bundler'

        Bundler.load.dependencies.reject! do |d|
          spec = d.to_spec

          if spec.gem_dir == Dir.pwd
            @gem_name = spec.name
          else
            spec.name == 'rspec_runner'
          end
        end

        if gem?
          Bundler.require(:default, :development)
        else
          Bundler.require(:default, :test)
        end

        $LOAD_PATH.unshift File.expand_path("#{Dir.pwd}/spec")

        fork_process
      end

      def execute(path)
        RSpec.configuration.start_time = Time.now
        RSpec::Core::Runner.run(filepaths(path))
      ensure
        reset_rspec!
      end

      def restart
        stop
        create_uri_file
        fork_process
      end

      def stop
        if @pid && @pid != 0
          # TODO: try to kill without -9
          send_signal('KILL')
        end
        delete_uri_file
      end

      private

      def gem?
        !!@gem_name
      end

      def fork_process
        @pid = fork do
          puts 'Preloading dependencies...'
          require @gem_name if gem?
          require 'spec_helper.rb'

          DRb.start_service(assign_uri, self)
          puts 'Server started!'

          DRb.thread.join
        end

        Process.detach(@pid) # so if the child exits, it dies
      end

      def send_signal(signal)
        Process.kill(signal, @pid)
      end

      def create_uri_file(uri = nil)
        dirname = File.dirname(RspecRunner.configuration.uri_filepath)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
        File.write(RspecRunner.configuration.uri_filepath, uri)
      end

      def delete_uri_file
        File.delete(RspecRunner.configuration.uri_filepath) if File.exist?(RspecRunner.configuration.uri_filepath)
      end

      def assign_uri
        socket = Socket.new(:INET, :STREAM, 0)
        socket.bind(Addrinfo.tcp('127.0.0.1'.freeze, 0))
        free_port = socket.local_address.ip_port
        uri = "druby://localhost:#{free_port}"

        if File.exist?(RspecRunner.configuration.uri_filepath)
          File.write(RspecRunner.configuration.uri_filepath, uri)
        else
          create_uri_file(uri)
        end

        uri
      end

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
        configuration.filter_manager = RSpec::Core::FilterManager.new if configuration.respond_to?(:filter_manager=)
        configuration.files_to_run = []
        configuration.files_or_directories_to_run = []
        configuration.seed = rand(0xFFFF) if configuration.seed_used?

        return unless configuration.respond_to?(:loaded_spec_files)
        set = configuration.loaded_spec_files
        set.each { |k| set.delete(k) }
      end
    end
  end
end
