$: << File.expand_path('../lib', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

unless defined?(Bundler)
  require 'rubygems'
  require 'bundler'
end

Bundler.setup(:default, :testing)

ENV['RACK_ENV'] ||= 'test'
ENV['CONFIGURATION_PATH'] = File.expand_path('../resources/config/common.yml', __FILE__)

require 'logger'
require 'sinatra'
require 'capybara'
require 'capybara/dsl'
require 'rack/test'
require 'central'


module Central
  module Logging
    def logger
      @logger ||= Logger.new(File.new('/dev/null', 'w'))
    end
  end
end

Spec::Runner.configure do |conf|
  conf.include(Rack::Test::Methods)
end


alias :running :lambda