$: << File.expand_path('../../lib', __FILE__)

begin
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'logger'
require 'burt_central'


module BurtCentral
  module Logging
    def logger
      @logger ||= Logger.new(File.new('/dev/null', 'w'))
    end
  end
end


alias :running :lambda