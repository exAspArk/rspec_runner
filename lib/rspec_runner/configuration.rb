module RspecRunner
  class Configuration
    attr_accessor :uri, :client_timeout, :watch_directories, :watch_pattern, :ignore_pattern

    def initialize
      @uri = 'druby://localhost:8787'.freeze
      @client_timeout = 10 # seconds
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
