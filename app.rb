require 'sinatra'
require 'mongo'
require 'json'
require 'less'
require 'central'


class App < Sinatra::Base
  
  configure do
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    enable :sessions
  end
  
  configure do
    configuration_path = ENV['CONFIGURATION_PATH'] || File.expand_path('../config/common.yml', __FILE__)
    $configuration = Central::Configuration.load(configuration_path, ENV['RACK_ENV'])
  end
  
  configure do
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked
          $configuration.reconnect_db
        end
      end
    end
  end
  
  helpers do
    include Central::Logging
    include Central::Utils
    
    def events_collection
      $configuration.events_collection
    end
    
    def password
      $configuration.password
    end
    
    def when_authenticated
      if session[:authenticated]
        yield
      elsif http_basic_authenticated?
        yield
      else
        status 401
      end
    end
    
    def http_basic_authenticated?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials.last == password
    end
  end

  before do
    content_type :json
  end
  
  get '/' do
    redirect 'index.html'
  end

  get '/history' do
    when_authenticated do
      options = {}
  
      if params[:limit] && params[:limit].to_i > 0
        options[:limit] = params[:limit].to_i
      else
        options[:since] = Time.now - (24 * 60 * 60)
      end
  
      history = Central::History.new
      history.restore(events_collection, options)
      history.events.map { |e| e.to_h }.to_json
    end
  end
  
  post '/history' do
    when_authenticated do
      begin
        event_hash = JSON.parse(request.body.read.to_s)
        event_hash = symbolize_keys(event_hash)
        if event_hash[:id] || event_hash[:url]
          event = Central::Event.new(event_hash)
          history = Central::History.new
          history.add_event(event)
          history.persist(events_collection)
          event.to_h.to_json
        else
          logger.debug('Event missing ID or URL')
          status 400
          ''
        end
      rescue JSON::ParserError => e
        logger.debug("JSON parsing error: #{e.message}")
        status 400
        ''
      end
    end
  end

  get '/types' do
    when_authenticated do
      events_collection.distinct(:type).to_json
    end
  end

  get '/ping' do
    when_authenticated do
      status 200
    end
  end
  
  post '/session' do
    if params[:password] == password
      session[:authenticated] = true
      status 200
    else
      status 401
    end
  end

  get '/styles/app.css' do
    content_type 'text/css', :charset => 'utf-8'
    less :app
  end

end