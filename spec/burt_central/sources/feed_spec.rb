require File.expand_path('../../../spec_helper', __FILE__)


describe BurtCentral::Sources::Feed do
  
  before do
    @entry1 = mock('Entry1', :id => '1', :title => 'Entry 1', :updated => Time.now - (24 * 60 * 60 * 1), :authors => [mock('Author1', :name => 'author 1')], :links => mock('Links1', :self => 'link1'))
    @entry2 = mock('Entry2', :id => '2', :title => 'Entry 2', :updated => Time.now - (24 * 60 * 60 * 2), :authors => [mock('Author2', :name => 'author 2')], :links => mock('Links2', :self => 'link2'))
    @entry3 = mock('Entry3', :id => '3', :title => 'Entry 3', :updated => Time.now - (24 * 60 * 60 * 3), :authors => [mock('Author3', :name => 'author 3')], :links => mock('Links3', :self => 'link3'))
    @time_before_all = Time.now - (24 * 60 * 60 * 4)
    @feed_loader = mock('FeedLoader')
    @source = BurtCentral::Sources::Feed.new('http://example.com/feed', @feed_loader)
  end
  
  it 'uses the feed loader to load the feed URL' do
    @feed_loader.should_receive(:load_feed).with(URI.parse('http://example.com/feed')).and_return(mock('Feed', :each_entry => nil))
    @source.events(@time_before_all)
  end
  
  it 'asks the feed loader for the entries since the specified date' do
    time = Time.now - 12 * 60
    feed = mock('Feed')
    feed.should_receive(:each_entry).with(hash_including(:since => time))
    @feed_loader.stub!(:load_feed).and_return(feed)
    @source.events(time)
  end
  
  it 'returns all entries in the feed as events' do
    feed = mock('Feed')
    feed.stub!(:each_entry).and_yield(@entry1).and_yield(@entry2).and_yield(@entry3)
    @feed_loader.stub!(:load_feed).and_return(feed)
    events = @source.events(@time_before_all)
    events.size.should == 3
    events.first.id.should == '1'
    events.first.title.should == 'Entry 1'
    events.last.id.should == '3'
    events.last.title.should == 'Entry 3'
  end
  
end