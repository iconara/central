$: << File.expand_path('../lib', __FILE__)

unless defined?(Bundler)
  require 'rubygems'
  require 'bundler'
end

ENV['RACK_ENV'] ||= 'development'

if ENV['RACK_ENV'] == 'production'
  Bundler.setup(:default, :production)
else
  Bundler.setup(:default)
end

require 'app'

run App