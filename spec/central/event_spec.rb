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
  
  describe '#date' do
    it 'returns the Time object that was passed to the constructor' do
      time  = Time.now
      event = Central::Event.new(:date => time)
      event.date.should == time
    end
    
    it 'parses a string passed as date' do
      event = Central::Event.new(:date => '2010-03-24')
      event.date.should == Time.local(2010, 3, 24)
    end
    
    it 'defaults to now if the date is missing' do
      event = Central::Event.new()
      event.date.to_i.should be_close(Time.now.to_i, 1)
    end
  end
  
  describe '#valid?' do
    context 'when all properties are set' do
      subject { Central::Event.new(:id => '3', :url => 'http://www.example.com/', :title => 'Test', :date => Time.now, :instigator => 'You', :type => 'example') }
      it { should be_valid }
    end

    context 'when no ID, but a URL is set' do
      subject { Central::Event.new(:url => 'http://www.example.com/', :title => 'Test', :date => Time.now, :instigator => 'You', :type => 'example') }
      it { should be_valid }
    end
    
    context 'when the title is empty' do
      subject { Central::Event.new(:id => '3', :url => 'http://www.example.com/', :title => '', :date => Time.now, :instigator => 'You', :type => 'example') }
      it { should_not be_valid }
    end
    
    context 'when the type is empty' do
      subject { Central::Event.new(:id => '3', :url => 'http://www.example.com/', :title => 'Test', :date => Time.now, :instigator => 'You', :type => '') }
      it { should_not be_valid }
    end
    
    context 'without instigator' do
      subject { Central::Event.new(:id => '3', :url => 'http://www.example.com/', :title => 'Test', :date => Time.now, :type => 'xyz') }
      it { should be_valid }
    end
    
    context 'without date' do
      subject { Central::Event.new(:id => '3', :url => 'http://www.example.com/', :title => 'Test', :date => nil, :instigator => 'You', :type => 'example') }
      it { should be_valid }
    end
  end
  
end