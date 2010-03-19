$: << File.expand_path('../lib', __FILE__)

require 'mongo'
require 'json'
require 'less'
require 'burt_central'


configure do
  configuration = BurtCentral::Configuration.load(File.expand_path('../config/common.yml', __FILE__))
  configuration.set!
  
  DATABASE = Mongo::Connection.new.db('burt_central')
  EVENTS_COLLECTION = DATABASE.collection('events')
end

get '/history/:limit' do
  content_type 'text/javascript', :charset => 'utf-8'
  history = BurtCentral::History.new
  history.restore(EVENTS_COLLECTION, :limit => params[:limit].to_i)
  history.events.map { |e| e.to_h }.to_json
end

get '/styles/app.css' do
  content_type 'text/css', :charset => 'utf-8'
  less :app
end