$: << File.expand_path('../lib', __FILE__)


begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'date'
require 'burt_central'


task :default => :events

task :events do
  configuration_path = File.expand_path('../config/common.yml', __FILE__)
  configuration = BurtCentral::Configuration.load(configuration_path)
  
  history = BurtCentral::History.new(configuration)
  history.events(Date.today).each do |event|
    puts '%s %6s %20s: %-40s %s' % [
      event.date.strftime('%Y-%m-%d'),
      event.type,
      event.instigator,
      event.title,
      event.url
    ]
  end
end