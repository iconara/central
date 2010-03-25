$: << File.expand_path('../lib', __FILE__)

begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'app'

run App