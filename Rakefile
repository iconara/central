$: << File.expand_path('../lib', __FILE__)


begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'mongo'
require 'spec/rake/spectask'
require 'burt_central'


task :default => :events

task :setup do
  configuration_path = File.expand_path('../config/common.yml', __FILE__)
  configuration = BurtCentral::Configuration.load(configuration_path)
  sources = [
    BurtCentral::Sources::PivotalTracker,
    BurtCentral::Sources::Github,
    BurtCentral::Sources::Hoptoad,
    BurtCentral::Sources::Highrise,
    BurtCentral::Sources::Twitter
  ]

  $database = Mongo::Connection.new.db('burt_central')
  $events_collection = $database.collection('events')
  
  $history = BurtCentral::History.new(configuration, sources)
end

task :events => :setup do
  $history.restore(events, Time.yesterday)
  $history.events.each do |event|
    puts '%s %6s %20s: %-40s %s' % [
      event.date.strftime('%Y-%m-%d'),
      event.type,
      event.instigator,
      event.title,
      event.url
    ]
  end
    
end

task :cache => :setup do
  #default_since = Time.local(2000, 1, 1)
  default_since = Time.today
  
  newest_item = $events_collection.find_one({}, {:fields => [:date], :sort => [:date, :descending]}) || {'date' => default_since}

  $history.load(newest_item['date'])
  $history.persist($events_collection)
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--options' << 'spec/spec.opts'
  spec.pattern = 'spec/**/*_spec.rb'
end