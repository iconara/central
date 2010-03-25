require 'sinatra'
require 'mongo'
require 'json'
require 'less'
require 'burt_central'


class App < Sinatra::Base
  
  configure do
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    
    configuration_path = File.expand_path('../config/common.yml', __FILE__)
    configuration = BurtCentral::Configuration.load(configuration_path, environment)
  
    set :events_collection, configuration.events_collection
  end

  before do
    content_type :json
  end
  
  get '/' do
    redirect 'index.html'
  end

  get '/history' do
    options = {}
  
    if params[:limit] && params[:limit].to_i > 0
      options[:limit] = params[:limit].to_i
    else
      options[:since] = Time.now - (24 * 60 * 60)
    end
  
    history = BurtCentral::History.new
    history.restore(settings.events_collection, options)
    history.events.map { |e| e.to_h }.to_json
  end

  get '/types' do
    settings.events_collection.distinct(:type).to_json
  end

  get '/styles/app.css' do
    content_type 'text/css', :charset => 'utf-8'
    less :app
  end

end