module RspecRunner
  CONFIG_FILEPATH = "#{Dir.pwd}/spec/rspec_runner.rb"

  class Configuration
    attr_accessor :uri_filepath, :client_timeout, :listen_directories, :listen_options

    def initialize
      @uri_filepath = "#{Dir.pwd}/tmp/rspec_runner"
      @client_timeout = 60 # seconds
      @listen_directories = [Dir.pwd]
      @listen_options = {only: /\.rb$/, ignore: /spec\/.+_spec\.rb$/, wait_for_delay: 1}
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  eval(File.new(CONFIG_FILEPATH).read) if File.exists?(CONFIG_FILEPATH)
end
