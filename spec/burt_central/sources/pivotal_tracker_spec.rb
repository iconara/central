require File.expand_path('../../../spec_helper', __FILE__)


describe BurtCentral::Sources::PivotalTracker do

  before do
    @api = double('PivotalTrackerApi')
    @source = BurtCentral::Sources::PivotalTracker.new(@api, '2345')
  end
  
  describe '#events' do
    it 'calls the API to find all project activity since the specified date' do
      @api.should_receive(:find) do |which, conditions|
        which.should == :all
        conditions[:params][:project_id].should == '2345'
        conditions[:params][:occurred_since_date].should == '04 May 2010'
        conditions[:params].should have_key(:limit)
      end
      @source.events(Time.utc(2010, 5, 4))
    end
    
    it 'creates an event out of relevant activities' do
      activities = [
        stub(:id => 1, :description => 'A.C. Clarke added comment "All sufficiently advanced technology, etc."', :author => 'A.C. Clarke', :occurred_at => Time.utc(2010, 5, 1, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/1'))),
        stub(:id => 2, :description => 'Carl Sagan finished "Contact"', :author => 'Carl Sagan', :occurred_at => Time.utc(2010, 5, 2, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/2'))),
        stub(:id => 3, :description => 'P.K. Dick edited "Do Androids, etc."', :author => 'P.K. Dick', :occurred_at => Time.utc(2010, 5, 3, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/3'))),

        stub(:id => 4, :description => 'Someone estimated "Some story"', :author => 'Someone', :occurred_at => Time.utc(2010, 5, 3, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/4'))),
        stub(:id => 5, :description => 'Someone restarted "Some story"', :author => 'Someone', :occurred_at => Time.utc(2010, 5, 3, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/5'))),
        stub(:id => 6, :description => 'Malformed description', :author => 'Someone', :occurred_at => Time.utc(2010, 5, 3, 10, 12), :stories => stub(:story => stub(:url => 'http://example.com/6'))),
      ]
      @api.stub(:find).and_return(activities)
      events = @source.events(Time.utc(2010, 5, 1))
      events.should have(3).items
      events[2].instigator.should == 'P.K. Dick'
      events[2].title.should == 'Do Androids, etc.'
      events[2].type.should == :edit
      events[2].date.should == Time.utc(2010, 5, 3, 10, 12)
      events[2].url.should == 'http://example.com/3'
    end
  end

end