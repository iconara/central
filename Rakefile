$: << File.expand_path('../lib', __FILE__)


begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'yaml'
require 'burt_central'


task :default => :events do
end

task :events => :config do
  BurtCentral::History.new.events(Date.yesterday).each do |event|
    puts '%s %6s %20s: %-40s %s' % [
      event.date.strftime('%Y-%m-%d'),
      event.type,
      event.instigator,
      event.title,
      event.url
    ]
  end
end

task :config do
  config_path = File.expand_path('../config/common.yml', __FILE__)
  config = YAML::load(open(config_path))
  BurtCentral::configure(config)
end