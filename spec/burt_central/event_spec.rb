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
    
    it 'puts the URL in the special key _id' do
      @hash[:_id].should == 'http://example.com'
    end
  end
  
end