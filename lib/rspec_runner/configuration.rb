module RspecRunner
  class Configuration
    attr_accessor :uri_filepath, :client_timeout, :watch_directories, :watch_pattern, :ignore_pattern

    def initialize
      @uri_filepath = "#{Dir.pwd}/tmp/rspec_runner"
      @client_timeout = 60 # seconds
      @watch_directories = ["#{Dir.pwd}"]
      @watch_pattern = /\.rb$/
      @ignore_pattern = /spec\/.+_spec\.rb$/
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
