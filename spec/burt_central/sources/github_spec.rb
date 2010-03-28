require File.expand_path('../../../spec_helper', __FILE__)


describe BurtCentral::Sources::Github do
  
  before do
    @api = mock('GithubApi')
    @source = BurtCentral::Sources::Github.new(@api)
  end
  
  describe '#events' do
    before do
      repository1 = {'name' => 'repo1'}
      repository2 = {'name' => 'repo2'}
      commit1 = {'id' => '1', 'committed_date' => Time.utc(2010, 3, 12, 10, 12).to_s, 'author' => {'name' => 'theo'},    'message' => "Lorem ipsum dolor sit amet\n\nconsectetur", 'url' => 'http://example.com/commit1'}
      commit2 = {'id' => '2', 'committed_date' => Time.utc(2010, 3,  5, 15,  3).to_s, 'author' => {'name' => 'daniel'},  'message' => "adipisicing elit\n\nsed do eiusmod tempor", 'url' => 'http://example.com/commit2'}
      commit3 = {'id' => '3', 'committed_date' => Time.utc(2010, 3, 10, 18, 23).to_s, 'author' => {'name' => 'fredrik'}, 'message' => "ut labore et dolore magna\n\naliqua",       'url' => 'http://example.com/commit3'}
      commit4 = {'id' => '4', 'committed_date' => Time.utc(2010, 3, 10,  8, 34).to_s, 'author' => {'name' => 'theo'},    'message' => "Ut enim ad minim veniam, quis nostrud",     'url' => 'http://example.com/commit4'}
      commit5 = {'id' => '5', 'committed_date' => Time.utc(2010, 3,  9, 23, 59).to_s, 'author' => {'name' => 'daniel'},  'message' => "exercitation ullamco laboris nisi",         'url' => 'http://example.com/commit5'}
      commits1 = [commit1, commit2]
      commits2 = [commit3, commit4]
      commits3 = [commit5]
      @api.stub!(:repositories).and_return([repository1, repository2])
      @api.stub!(:commits).with(repository1, 1).and_return(commits1)
      @api.stub!(:commits).with(repository2, 1).and_return(commits2)
      @api.stub!(:commits).with(repository2, 2).and_return(commits3)
    end
    
    it 'loads all commits after the specified date form all repositories' do
      events = @source.events(Time.utc(2010, 3, 10))
      events.size.should == 3
      events[0].id.should == '1'
      events[1].id.should == '3'
      events[2].id.should == '4'
    end
    
    it 'prepends the repository name to the commit message' do
      @source.events(Time.utc(2010, 3, 10)).first.title.should match(/^repo1:/)
    end
    
    it 'uses the first line of the commit message as the event title' do
      @source.events(Time.utc(2010, 3, 10)).first.title.should == 'repo1: Lorem ipsum dolor sit amet'
    end
    
    it 'extracts the relevant parts of the commits and builds events' do
      events = @source.events(Time.utc(2010, 3, 10))
      events[2].id.should == '4'
      events[2].title.should == 'repo2: Ut enim ad minim veniam, quis nostrud'
      events[2].date.should == Time.utc(2010, 3, 10,  8, 34)
      events[2].instigator.should == 'theo'
      events[2].url.should == 'http://example.com/commit4'
      events[2].type.should == :commit
    end
  end
  
end

describe BurtCentral::Sources::GithubApi do
  
  before do
    @http = mock('HTTP')
    @api = BurtCentral::Sources::GithubApi.new('tog', 'xyz', @http)
  end
  
  describe '#repositories' do
    it 'requests the right URL' do
      @http.should_receive(:get).with(%r(https://github.com/api/v2/\w+/repos/show/tog), :query => {:login => 'tog', :token => 'xyz'})
      @api.repositories
    end
    
    it 'strips the first level off of the returned hash' do
      @http.stub!(:get).and_return({'repositories' => 'a list of repositories'})
      @api.repositories.should == 'a list of repositories'
    end
    
    it 'returns an empty list if the response is nil' do
      @http.stub!(:get).and_return(nil)
      @api.repositories.should be_empty
    end

    it 'returns an empty list if the response does not have the expected structure' do
      @http.stub!(:get).and_return({})
      @api.repositories.should be_empty
    end
  end
  
  describe '#commits' do
    it 'requests the right URL, when the repository is private' do
      @http.should_receive(:get).with(%r(https://github.com/api/v2/\w+/commits/list/tog/repo1/master), :query => {:page => 3, :login => 'tog', :token => 'xyz'})
      @api.commits({'name' => 'repo1', 'private' => true}, 3)
    end

    it 'requests the right URL, when the repository is public' do
      @http.should_receive(:get).with(%r(http://github.com/api/v2/\w+/commits/list/tog/repo1/master), :query => {:page => 3, :login => 'tog', :token => 'xyz'})
      @api.commits({'name' => 'repo1', 'private' => false}, 3)
    end
    
    it 'strips the first level off of the returned hash' do
      @http.stub!(:get).and_return({'commits' => 'a list of commits'})
      @api.commits({'name' => 'repo1'}).should == 'a list of commits'
    end
    
    it 'returns an empty list if the response is nil' do
      @http.stub!(:get).and_return(nil)
      @api.commits({'name' => 'repo1'}).should be_empty
    end

    it 'returns an empty list if the response does not have the expected structure' do
      @http.stub!(:get).and_return({})
      @api.commits({'name' => 'repo1'}).should be_empty
    end
  end
  
end