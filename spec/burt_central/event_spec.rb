require File.expand_path('../../spec_helper', __FILE__)


describe BurtCentral::Event do
  
  describe '#to_h' do
    before do
      @hash = BurtCentral::Event.new(:title => 'Hello world', :date => Time.today, :instigator => 'Phil', :url => 'http://example.com', :type => :test).to_h
    end
    
    it 'creates a hash from the event' do
      @hash[:title].should == 'Hello world'
      @hash[:date].should == Time.today
      @hash[:instigator].should == 'Phil'
      @hash[:url].should == 'http://example.com'
      @hash[:type].should == :test
    end
  end
  
  describe '#eql?' do
    it 'is equal to another event with the same URL' do
      BurtCentral::Event.new(:url => 'http://example.com/1').should eql(BurtCentral::Event.new(:url => 'http://example.com/1'))
    end

    it 'is equal to another object with the same URL' do
      obj = Object.new
      def obj.url; 'http://example.com/1' end
      BurtCentral::Event.new(:url => 'http://example.com/1').should eql(obj)
    end
    
    it 'is not equal to an event with another URL' do
      BurtCentral::Event.new(:url => 'http://example.com/1').should_not eql(BurtCentral::Event.new(:url => 'http://example.com/2'))
    end
    
    it 'responds to == in the same was as eql?' do
      BurtCentral::Event.new(:url => 'http://example.com/1').should     == (BurtCentral::Event.new(:url => 'http://example.com/1'))
      BurtCentral::Event.new(:url => 'http://example.com/1').should_not == (BurtCentral::Event.new(:url => 'http://example.com/2'))
    end
  end
  
end