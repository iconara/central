require File.expand_path('../../../spec_helper', __FILE__)


describe Central::Sources::Hoptoad do

  before do
    @api = mock('HoptoadApi')
    @hoptoad = Central::Sources::Hoptoad.new(@api)
  end

  describe '#events' do
    before do
      error1 = mock('Error1', :id => '1', :error_message => 'Something new went wrong',     :most_recent_notice_at => Time.utc(2010, 3, 29, 12, 43), :rails_env => 'production')
      error2 = mock('Error2', :id => '2', :error_message => 'Something else went wrong',    :most_recent_notice_at => Time.utc(2010, 3, 10, 23, 21), :rails_env => 'staging')
      error3 = mock('Error2', :id => '3', :error_message => 'Something strange went wrong', :most_recent_notice_at => Time.utc(2010, 3, 10, 18, 10), :rails_env => 'production')
      error4 = mock('Error3', :id => '4', :error_message => 'Something went wrong',         :most_recent_notice_at => Time.utc(2010, 3,  9, 12,  1), :rails_env => 'production')
      @api.stub!(:find).with(:all).and_return([error1, error2, error3, error4])
      @api.stub!(:site).and_return(URI.parse('http://example.com'))
      @events = @hoptoad.events(Time.utc(2010, 3, 10))
    end
    
    it 'creates events of all errors from production since the specified date' do
      @events.size.should == 2
      @events.first.title.should == 'Something new went wrong'
      @events.last.title.should  == 'Something strange went wrong'
    end
    
    it 'sets the correct URL' do
      @events.first.url.should == 'http://example.com/errors/1'
    end
    
    it 'sets the correct type' do
      @events.last.type.should == :error
    end
  end

end