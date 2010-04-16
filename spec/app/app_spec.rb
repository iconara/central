require File.expand_path('../../spec_helper', __FILE__)
require 'yaml'
require 'app'


describe 'Central Webapp' do
  
  before(:all) do
    @configuration = Central::Configuration.load(ENV['CONFIGURATION_PATH'], :test)
    @events_collection = @configuration.events_collection

    @events_collection.remove

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
  
  after(:all) do
    @events_collection.remove
  end
  
  context 'authentication' do
    def app
      App
    end
    
    it 'redirects / to /index.html' do
      get '/'
      last_response.should be_redirect
      last_response.location.should == 'index.html'
    end

    it 'responds with 401 unauthorized when the wrong password is passed to /session' do
      post '/session', {:password => 'xyz'}
      last_response.status.should == 401
    end
    
    it 'authenticates via a post to /session' do
      post '/session', {:password => 'password'}
      last_response.should be_ok
    end
    
    %w(/history /types /ping).each do |path|
      it "disallows #{path} from non-authenticated users" do
        get path
        last_response.status.should == 401
      end
      
      it "allows #{path} when the user is authenticated" do
        post '/session', {:password => 'password'}
        get path
        last_response.should be_ok
      end
    end
  end
  
  context 'as a user' do
    before do
      @session = Capybara::Session.new(:selenium, App)
      @session.visit('/index.html')
    end
    
    context 'when not logged in' do
      it 'shows a log in form' do
        @session.should have_content('Password')
        @session.should have_css('input[type=password]')
      end
    end
  
    context 'when logged in' do
      before do
        if @session.find(:css, '#login-form').visible?
          @session.fill_in('Password', :with => 'password')
          @session.click('Ok')
        end
      end
    
      it 'loads events and displays them' do
        @session.should have_content('The message is a massage')
        @session.should have_content('All good things come to a beginning')
      end
  
      it 'creates a legend from the event types' do
        @session.should have_content('rambling')
        @session.should have_content('nonsense')
      end
    end
  end
  
end