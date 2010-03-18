$: << File.expand_path('../lib', __FILE__)


begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  
  Bundler.setup
end

require 'mongo'
require 'burt_central'


task :default => :events

task :events do
  configuration_path = File.expand_path('../config/common.yml', __FILE__)
  configuration = BurtCentral::Configuration.load(configuration_path)
  sources = [
    BurtCentral::Sources::PivotalTracker,
    BurtCentral::Sources::Github,
    BurtCentral::Sources::Hoptoad,
    BurtCentral::Sources::Highrise,
    BurtCentral::Sources::Twitter
  ]

  database = Mongo::Connection.new.db('burt_central')
  events = database.collection('events')
  
  history = BurtCentral::History.new(configuration, sources)
  history.restore(events)
  
  history.events.each do |event|
    puts '%s %6s %20s: %-40s %s' % [
      event.date.strftime('%Y-%m-%d'),
      event.type,
      event.instigator,
      event.title,
      event.url
    ]
  end
    
end

task :cache do
  configuration_path = File.expand_path('../config/common.yml', __FILE__)
  configuration = BurtCentral::Configuration.load(configuration_path)
  sources = [
    BurtCentral::Sources::PivotalTracker,
    BurtCentral::Sources::Github,
    BurtCentral::Sources::Hoptoad,
    BurtCentral::Sources::Highrise,
    BurtCentral::Sources::Twitter
  ]

  database = Mongo::Connection.new.db('burt_central')
  events = database.collection('events')
  
  since = Time.local(2000, 1, 1)
  
  item = events.find_one({}, {:fields => [:date], :sort => [:date, :descending]})
  
  since = item['date'] if item

  history = BurtCentral::History.new(configuration, sources)
  history.load(since)
  
  history.persist(events)
end