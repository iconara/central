require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../spec_helper', __FILE__)


describe 'Central Webapp REST API' do
  
  def app
    App
  end
  
  before do
    @events_collection.save({
      :_id => 'http://example.com/a',
      :title => 'The message is a massage',
      :url => 'http://example.com/a',
      :instigator => 'Mike',
      :date => Time.now,
      :type => :rambling
    })
    @events_collection.save({
      :_id => 'http://example.com/b',
      :title => 'All good things come to a beginning',
      :url => 'http://example.com/b',
      :instigator => 'Phil',
      :date => Time.now - (12 * 60 * 60),
      :type => :nonsense
    })
  end

  describe '/history' do
    context 'GET' do
      before do
        post '/session', {:password => 'password'}
        get '/history'
      end
      
      it 'responds with JSON' do
        last_response.content_type.should == 'application/json'
      end
            
      it 'responds with the event history' do
        JSON.parse(last_response.body).should have(2).items
      end
    end
    
    context 'POST' do
      before do
        @event = {
          :title => 'Most of the time you win',
          :url => 'http://example.com/c',
          :instigator => 'Steve',
          :date => Time.now + 3,
          :type => :future
        }
        @http_credentials = http_credentials('someone', 'password')
      end
      
      it 'adds the POSTed event to the event history' do
        post '/history', @event.to_json, @http_credentials
        @events_collection.count().should == 3
      end
      
      it 'responds with the saved event' do
        post '/history', @event.to_json, @http_credentials
        JSON.parse(last_response.body)['title'].should == 'Most of the time you win'
      end
      
      it 'rejects malformed data' do
        post '/history', 'abc', @http_credentials
        last_response.status.should == 400
      end
      
      it 'rejects events without ID and URL' do
        @event.delete(:url)
        post '/history', @event.to_json, @http_credentials
        last_response.status.should == 400
      end
      
      it 'rejects events without a title' do
        @event[:title] = ''
        post '/history', @event.to_json, @http_credentials
        last_response.status.should == 400
      end
      
      it 'rejects events without a type' do
        @event[:type] = nil
        post '/history', @event.to_json, @http_credentials
        last_response.status.should == 400
      end
      
      it 'rejects JSON that is not a hash' do
        post '/history', [@event].to_json, @http_credentials
        last_response.status.should == 400
      end
    end
  end
  
end