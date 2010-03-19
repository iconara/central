require File.expand_path('../../spec_helper', __FILE__)


describe BurtCentral::History do

  before do
    @date = Time.utc(2010, 3, 14)
    @event1 = BurtCentral::Event.new(:url => 'http://example.com/1', :title => 'Eventful',    :date => Time.utc(2010, 3, 10), :instigator => 'You',     :type => :tweet)
    @event2 = BurtCentral::Event.new(:url => 'http://example.com/2', :title => 'Foo',         :date => Time.utc(2010, 3, 15), :instigator => 'Me',      :type => :story)
    @event3 = BurtCentral::Event.new(:url => 'http://example.com/3', :title => 'Bar',         :date => Time.utc(2010, 3, 14), :instigator => 'Someone', :type => :error)
    @event4 = BurtCentral::Event.new(:url => 'http://example.com/4', :title => 'Hello World', :date => Time.utc(2010, 2, 28), :instigator => 'Him',     :type => :tweet)
    @event1_h = @event1.to_h
    @event1_h[:_id] = @event1_h.delete(:url)
    @event2_h = @event2.to_h
    @event2_h[:_id] = @event2_h.delete(:url)
    @event3_h = @event3.to_h
    @event3_h[:_id] = @event3_h.delete(:url)
    @event4_h = @event4.to_h
    @event4_h[:_id] = @event4_h.delete(:url)
    @source1 = mock('Source1')
    @source2 = mock('Source2')
    @source1_class = mock('Source1Class', :new => @source1)
    @source2_class = mock('Source2Class', :new => @source2)
    @source1.stub!(:events).with(@date).and_return([@event1, @event2])
    @source2.stub!(:events).with(@date).and_return([@event3, @event4])
    @configuration = mock('Configuration')
    @configuration.stub!(:set)
    @history = BurtCentral::History.new(@configuration, [@source1_class, @source2_class])
    @repository = mock('Repository')
  end

  describe '#load' do
    it 'asks each source for it\'s events' do
      @source1.should_receive(:events).with(@date).and_return([])
      @source2.should_receive(:events).with(@date).and_return([])
      @history.load(@date)
    end
    
    it 'collects the events returned by the sources, most recent first' do
      @history.load(@date)
      @history.events.should == [@event2, @event3, @event1, @event4]
    end
  end

  describe '#persist' do
    it 'asks the repository to save each event' do
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/1', :title => 'Eventful'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/2', :title => 'Foo'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/3', :title => 'Bar'))
      @repository.should_receive(:save).with(hash_including(:_id => 'http://example.com/4', :title => 'Hello World'))
      @history.load(@date)
      @history.persist(@repository)
    end
  end
  
  describe '#restore' do
    it 'asks the repository for events and creates Event objects' do
      @repository.should_receive(:find).with({:date => {'$gt' => Time.today.getutc}}, {:sort => [:date, :descending]}).and_return([@event2_h, @event3_h, @event1_h, @event4_h])
      @history.restore(@repository)
      @history.events.should == [@event2, @event3, @event1, @event4]
    end
    
    it 'asks the repository for events with date >= the specified date' do
      @date = Time.utc(2010, 3, 13)
      @repository.should_receive(:find).with({:date => {'$gt' => @date}}, {:sort => [:date, :descending]}).and_return([@event2_h, @event3_h])
      @history.restore(@repository, @date)
      @history.events.should == [@event2, @event3]
    end
  end
  
end