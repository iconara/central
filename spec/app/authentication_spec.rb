require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../spec_helper', __FILE__)


describe 'Central Webapp Authentication' do
  
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
  
  it 'disallows POSTs to /history from non-authenticated users' do
    post '/history'
    last_response.status.should == 401
  end

  context 'HTTP authentication' do
    it 'accepts authentication over HTTP when the password is right' do
      post '/history', {}, http_credentials('someone', 'password')
      last_response.status.should_not == 401
    end
    
    it 'rejects authentication over HTTP when the password is wrong' do
      post '/history', {}, http_credentials('someone', '1235')
      last_response.status.should == 401
    end
  end

end