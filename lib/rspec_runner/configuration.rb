module RspecRunner
  class Configuration
    attr_accessor :uri, :client_timeout, :watch_directories, :watch_pattern

    def initialize
      @uri = 'druby://localhost:8787'.freeze
      @client_timeout = 10 # seconds
      @watch_directories = ["#{Dir.pwd}/app", "#{Dir.pwd}/lib"]
      @watch_pattern = /\.rb$/
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
