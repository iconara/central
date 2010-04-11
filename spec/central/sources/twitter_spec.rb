require File.expand_path('../../../spec_helper', __FILE__)


describe Central::Sources::Twitter do
  
  before do
    @api = mock('TwitterApi')
    @twitter = Central::Sources::Twitter.new(@api, 'tog', 'enemies')
  end
  
  describe '#events' do
    before do
      tweet1 = mock('Tweet1', :id => '1', :text => 'One tweet', :created_at => Time.utc(2010, 3, 13, 12, 34).to_s, :user => mock('User1', :name => 'User Name 1', :screen_name => 'screen_name_1'))
      tweet2 = mock('Tweet1', :id => '2', :text => 'Two tweet', :created_at => Time.utc(2010, 3, 12, 23, 45).to_s, :user => mock('User2', :name => 'User Name 1', :screen_name => 'screen_name_2'))
      tweet3 = mock('Tweet1', :id => '3', :text => '3 tweet',   :created_at => Time.utc(2010, 3, 10,  1, 23).to_s, :user => mock('User3', :name => 'User Name 1', :screen_name => 'screen_name_3'))
      @api.stub!(:list_timeline).with('tog', 'enemies', :page => 1).and_return([tweet1, tweet2])
      @api.stub!(:list_timeline).with('tog', 'enemies', :page => 2).and_return([tweet3])
      @events = @twitter.events(Time.utc(2010, 3, 11))
    end
    
    it 'creates events from all tweets newer than the specified date' do
      @events.size.should == 2
      @events.first.title.should == 'One tweet'
      @events.last.title.should == 'Two tweet'
    end
    
    it 'sets the right URL' do
      @events.first.url.should == 'http://twitter.com/screen_name_1/status/1'
    end
    
    it 'sets the correct date' do
      @events.first.date.should == Time.utc(2010, 3, 13, 12, 34)
    end
    
    it 'sets the correct event instigator' do
      @events.first.instigator.should == 'User Name 1'
    end
    
    it 'sets the right type' do
      @events.first.type.should == :tweet
    end
  end
  
end
