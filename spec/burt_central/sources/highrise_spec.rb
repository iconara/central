require File.expand_path('../../../spec_helper', __FILE__)


describe BurtCentral::Sources::Highrise do
  
  before do
    @user_api = mock('UserApi')
    @case_api = mock('CaseApi')
    @highrise = BurtCentral::Sources::Highrise.new(@user_api, @case_api)
  end
  
  describe '#events' do
    before do
      user1 = mock('User1', :id => '1', :name => 'Author 1')
      user2 = mock('User2', :id => '2', :name => 'Author 2')
      user3 = mock('User3', :id => '3', :name => 'Author 3')
      note1 = mock('Note1', :id => '1', :subject_name => 'Subject Name 1', :updated_at => Time.utc(2010, 3, 14, 18, 48), :author_id => '1')
      note2 = mock('Note2', :id => '2', :subject_name => 'Subject Name 2', :updated_at => Time.utc(2010, 3, 10, 12, 14), :author_id => '2')
      note3 = mock('Note3', :id => '3', :subject_name => 'Subject Name 3', :updated_at => Time.utc(2010, 3, 12, 10, 11), :author_id => '3')
      note4 = mock('Note4', :id => '4', :subject_name => 'Subject Name 4', :updated_at => Time.utc(2010, 3, 10,  8,  1), :author_id => '1')
      note5 = mock('Note5', :id => '5', :subject_name => 'Subject Name 5', :updated_at => Time.utc(2010, 3, 10, 23, 59), :author_id => '2')
      case1 = mock('Case1')
      case2 = mock('Case2')
      case1.stub!(:notes).with(:since => '20100310').and_return([note1, note2])
      case2.stub!(:notes).with(:since => '20100310').and_return([note3, note4, note5])
      @case_api.stub!(:site).and_return(URI.parse('http://example.com'))
      @user_api.stub!(:find).with(:all).and_return([user1, user2, user3])
      @case_api.stub!(:find).with(:all, :from => :open).and_return([case1, case2])
      @events = @highrise.events(Time.utc(2010, 3, 10))
    end
    
    # there no test of date logic since the API handles that (the notes are
    # loaded with :since => date)
    
    it 'loads all case notes' do
      @events.size == 5
    end
    
    it 'uses the subject name as event title' do
      @events.first.title.should == 'Subject Name 1'
    end
    
    it 'uses the author name as instigator' do
      @events[1].instigator.should == 'Author 2'
    end
    
    it 'sets the correct URL' do
      @events[2].url.should == 'https://example.com/notes/3'
    end
    
    it 'sets the correct type' do
      @events[3].type.should == :case_note
    end
    
    it 'sets the right date' do
      @events[4].date.should == Time.utc(2010, 3, 10, 23, 59)
    end
  end
  
end
