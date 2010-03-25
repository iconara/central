$: << File.expand_path('../lib', __FILE__)

require 'mongo'
require 'json'
require 'less'
require 'burt_central'


configure do
  configuration = BurtCentral::Configuration.load(File.expand_path('../config/common.yml', __FILE__))
  
  DATABASE = Mongo::Connection.new.db('burt_central')
  EVENTS_COLLECTION = DATABASE.collection('events')
end

before do
  content_type :json
end

get '/history' do
  options = {}
  
  if params[:limit] && params[:limit].to_i > 0
    options[:limit] = params[:limit].to_i
  else
    options[:since] = Time.now - (24 * 60 * 60)
  end
  
  history = BurtCentral::History.new
  history.restore(EVENTS_COLLECTION, options)
  history.events.map { |e| e.to_h }.to_json
end

get '/types' do
  EVENTS_COLLECTION.distinct(:type).to_json
end

get '/styles/app.css' do
  content_type 'text/css', :charset => 'utf-8'
  less :app
end
