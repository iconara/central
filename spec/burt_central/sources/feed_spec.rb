require File.expand_path('../../../spec_helper', __FILE__)


describe BurtCentral::Sources::Feed do
  
  before do
    @source = BurtCentral::Sources::Feed.new(File.expand_path('../../../resources/feed.xml', __FILE__))
  end
  
  it 'returns all entries in the feed newer than the specified date' do
    events = @source.events(Time.utc(2010, 3, 10))
    events.size.should == 6
    events.first.id.should == 'tag:github.com,2008:Post/622'
    events.first.title.should == 'Inline commit notes'
    events.first.date.should == Time.utc(2010, 3, 27, 9, 41, 11)
    events.first.instigator.should == 'kneath'
    events.first.type.should == :blogpost
    events.last.date.should == Time.utc(2010, 3, 10, 20, 5, 5)
  end
  
end