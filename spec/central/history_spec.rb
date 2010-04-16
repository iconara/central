require File.expand_path('../../spec_helper', __FILE__)


describe Central::History do

  before do
    @date = Time.utc(2010, 3, 14)
    @event1 = Central::Event.new(:id => 'http://example.com/1', :url => 'http://example.com/1', :title => 'Eventful',    :date => Time.utc(2010, 3, 10), :instigator => 'You',     :type => :tweet)
    @event2 = Central::Event.new(:id => 'http://example.com/2', :url => 'http://example.com/2', :title => 'Foo',         :date => Time.utc(2010, 3, 15), :instigator => 'Me',      :type => :story)
    @event3 = Central::Event.new(:id => 'http://example.com/3', :url => 'http://example.com/3', :title => 'Bar',         :date => Time.utc(2010, 3, 14), :instigator => 'Someone', :type => :error)
    @event4 = Central::Event.new(:id => 'http://example.com/4', :url => 'http://example.com/4', :title => 'Hello World', :date => Time.utc(2010, 2, 28), :instigator => 'Him',     :type => :tweet)
    @event1_h = @event1.to_h
    @event1_h[:_id] = @event1_h.delete(:id)
    @event2_h = @event2.to_h
    @event2_h[:_id] = @event2_h.delete(:id)
    @event3_h = @event3.to_h
    @event3_h[:_id] = @event3_h.delete(:id)
    @event4_h = @event4.to_h
    @event4_h[:_id] = @event4_h.delete(:id)
    @source1 = mock('Source1')
    @source2 = mock('Source2')
    @source1.stub!(:events).with(@date).and_return([@event1, @event2])
    @source2.stub!(:events).with(@date).and_return([@event3, @event4])
    @history = Central::History.new
    @repository = mock('Repository')
  end

  describe '#load' do
    it 'asks each source for it\'s events' do
      @source1.should_receive(:events).with(@date).and_return([])
      @source2.should_receive(:events).with(@date).and_return([])
      @history.load([@source1, @source2], :since => @date)
    end
    
    it 'collects the events returned by the sources, most recent first' do
      @history.load([@source1, @source2], :since => @date)
      @history.events.should == [@event2, @event3, @event1, @event4]
    end
  end

  describe '#persist' do
    it 'asks the repository to save each event' do
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/1', :title => 'Eventful'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/2', :title => 'Foo'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/3', :title => 'Bar'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/4', :title => 'Hello World'))
      @history.load([@source1, @source2], :since => @date)
      @history.persist(@repository)
    end
  end
  
  describe '#restore' do
    it 'asks the repository for events and creates Event objects' do
      @repository.should_receive(:find).with({:date => {'$gt' => Time.utc(Time.now.year, Time.now.month, Time.now.day)}}, {:sort => [:date, :descending]}).and_return([@event2_h, @event3_h, @event1_h, @event4_h])
      @history.restore(@repository)
      @history.events.should == [@event2, @event3, @event1, @event4]
    end
    
    it 'asks the repository for events since a specified date' do
      @date = Time.utc(2010, 3, 13)
      @repository.should_receive(:find).with({:date => {'$gt' => @date}}, {:sort => [:date, :descending]}).and_return([@event2_h, @event3_h])
      @history.restore(@repository, :since => @date)
      @history.events.should == [@event2, @event3]
    end
    
    it 'asks the repository for the N most recent events' do
      @repository.should_receive(:find).with({}, {:sort => [:date, :descending], :limit => 3}).and_return([@event2_h, @event3_h, @event1_h])
      @history.restore(@repository, :limit => 3)
      @history.events.should == [@event2, @event3, @event1]
    end
  end
 
  describe '#add_event' do
    it 'adds the event to the list of events' do
      @history.add_event(@event1)
      @history.events.should have(1).items
    end
    
    it 'keeps the list of events ordered' do
      @history.add_event(@event1)
      @history.add_event(@event2)
      @history.add_event(@event3)
      @history.add_event(@event4)
      @history.events.should == [@event2, @event3, @event1, @event4]
    end
  end
  
end