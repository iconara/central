$: << File.expand_path('../lib', __FILE__)

require 'mongo'
require 'json'
require 'burt_central'


configure do
  CONFIGURATION = BurtCentral::Configuration.load(File.expand_path('../config/common.yml', __FILE__))
  
  DATABASE = Mongo::Connection.new.db('burt_central')
  EVENTS_COLLECTION = DATABASE.collection('events')
end

get '/history' do
  content_type 'text/javascript', :charset => 'utf-8'
  history = BurtCentral::History.new(CONFIGURATION)
  history.restore(EVENTS_COLLECTION, Time.yesterday)
  history.events.map { |e| e.to_h }.to_json
end