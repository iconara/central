require File.expand_path('../../spec_helper', __FILE__)


describe Central::Event do
  
  describe '#initialize' do
    it 'sets #id to the same value as #url if no ID was specified' do
      @event = Central::Event.new(:url => 'http://example.com/1')
      @event.id.should == 'http://example.com/1'
    end
    
    it 'does not set #id to the same value as #url if an ID is specified' do
      @event = Central::Event.new(:id => 3, :url => 'http://example.com/1')
      @event.id.should == 3
    end
  end
  
  describe '#to_h' do
    before do
      @hash = Central::Event.new(:id => 'abc', :title => 'Hello world', :date => Time.today, :instigator => 'Phil', :url => 'http://example.com', :type => :test).to_h
    end
    
    it 'creates a hash from the event' do
      @hash[:id].should == 'abc'
      @hash[:title].should == 'Hello world'
      @hash[:date].should == Time.today
      @hash[:instigator].should == 'Phil'
      @hash[:url].should == 'http://example.com'
      @hash[:type].should == :test
    end
    
    it 'sets :id to the same value as :url if no ID was specified' do
      @hash = Central::Event.new(:url => 'http://example.com').to_h
      @hash[:id].should == 'http://example.com'
    end
  end
  
  describe '#eql?' do
    it 'is equal to another event with the same ID' do
      Central::Event.new(:id => 'abc123').should eql(Central::Event.new(:id => 'abc123'))
    end

    it 'is equal to another object with the same ID' do
      obj = Object.new
      def obj.id; 'abc123' end
      Central::Event.new(:id => 'abc123').should eql(obj)
    end
    
    it 'is not equal to an event with another ID' do
      Central::Event.new(:id => 'abc123').should_not eql(Central::Event.new(:id => 'def456'))
    end
    
    it 'responds to == in the same was as eql?' do
      Central::Event.new(:id => 'abc123').should     == (Central::Event.new(:id => 'abc123'))
      Central::Event.new(:id => 'abc123').should_not == (Central::Event.new(:id => 'def456'))
    end
  end
  
end